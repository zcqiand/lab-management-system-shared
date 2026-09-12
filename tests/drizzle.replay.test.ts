// tests/drizzle.replay.test.ts — target DDL schema replay（ADR-0033 阶段一）
//
// 从空 schema 起 drizzle-kit push 全量重建测试库，校验 lab 家族的
// 租户隔离列、字典 junction 图与 cascade 链。替代原 sql.replay.test.ts。

import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createRequire } from "node:module";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");

type PgClient = {
  connect(): Promise<void>;
  query<R = unknown>(
    sql: string,
    params?: unknown[],
  ): Promise<{ rows: R[]; rowCount: number }>;
  end(): Promise<void>;
};

let pgModule: { Client: new (cfg: unknown) => PgClient } | null = null;
try {
  const requireFromNext = createRequire(
    resolve(SHARED_ROOT, "../lab-management-system-nextjs/package.json"),
  );
  pgModule = requireFromNext("pg") as { Client: new (cfg: unknown) => PgClient };
} catch {
  // shared 契约仓不装 pg runtime 依赖，借 nextjs 的；借不到则 skip。
}

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} env required`);
  return value;
}

const REQUIRED_PG_ENV = [
  "PG_HOST",
  "PG_PORT",
  "PG_USER",
  "PG_PASSWORD",
  "PG_DATABASE_TEST",
];
const allPgEnvPresent = REQUIRED_PG_ENV.every((name) => !!process.env[name]);

// 25 张业务表（与 src/db/schema.ts 一一对应；簿记表 flyway_schema_history /
// __schema_migrations / __drizzle_migrations 不在目标模型里）
const EXPECTED_TABLES = [
  "audit_events",
  "contracts",
  "inspection_brands",
  "inspection_calculation_methods",
  "inspection_grades",
  "inspection_models",
  "inspection_object_parameters",
  "inspection_object_report_names",
  "inspection_object_standards",
  "inspection_objects",
  "inspection_param_interface_links",
  "inspection_param_interfaces",
  "inspection_parameters",
  "inspection_report_name_parameters",
  "inspection_report_name_standards",
  "inspection_report_names",
  "inspection_specialties",
  "inspection_specialty_objects",
  "inspection_specs",
  "inspection_standard_parameters",
  "inspection_standards",
  "inspection_technical_requirements",
  "sample_receipts",
  "samples",
  "test_records",
];

describe("target DDL schema replay", () => {
  if (!pgModule || process.env.PG_REPLAY_SKIP === "1" || !allPgEnvPresent) {
    it.skip("pg driver or required PG_* env not available", () => {});
    return;
  }

  let client: PgClient | null = null;

  beforeAll(async () => {
    client = new pgModule!.Client({
      host: requireEnv("PG_HOST"),
      port: Number(requireEnv("PG_PORT")),
      user: requireEnv("PG_USER"),
      password: requireEnv("PG_PASSWORD"),
      database: requireEnv("PG_DATABASE_TEST"),
      connectionTimeoutMillis: 5000,
    });
    await client.connect();
    await client.query("DROP SCHEMA IF EXISTS public CASCADE");
    await client.query("CREATE SCHEMA public");

    // Windows：spawnSync("npx") 无法解析 npx.cmd（ENOENT → status null），
    // push 根本没跑、断言却报 "exited null"。win32 走 npx.cmd + shell；
    // 断言强度不变（status 必须 === 0），Linux 行为不变。
    const isWin = process.platform === "win32";
    const result = spawnSync(
      isWin ? "npx.cmd" : "npx",
      [
        "--no",
        "drizzle-kit",
        "push",
        "--config",
        "drizzle.config.ts",
        "--force",
      ],
      {
        cwd: SHARED_ROOT,
        env: {
          ...process.env,
          PG_DATABASE: requireEnv("PG_DATABASE_TEST"),
        },
        stdio: "inherit",
        shell: isWin,
      },
    );
    if (result.status !== 0) {
      throw new Error(`drizzle-kit push exited ${result.status}`);
    }
  }, 60000);

  afterAll(async () => {
    if (client) await client.end();
  });

  it("creates exactly the target tables", async () => {
    if (!client) return;
    const { rows } = await client.query<{ table_name: string }>(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name",
    );
    expect(rows.map((row) => row.table_name)).toEqual(EXPECTED_TABLES);
  });

  it("keeps the single audit_action enum and TEXT-only value columns", async () => {
    if (!client) return;
    const { rows: enums } = await client.query<{ typname: string }>(
      `SELECT t.typname FROM pg_type t
       WHERE t.typnamespace = 'public'::regnamespace AND t.typtype = 'e'
       ORDER BY t.typname`,
    );
    // V014 后 12 个业务 enum 全部 TEXT 化，仅 audit_action 保留 PG enum
    expect(enums.map((r) => r.typname)).toEqual(["audit_action"]);

    const { rows: statusCols } = await client.query<{ data_type: string }>(
      `SELECT data_type FROM information_schema.columns
       WHERE table_schema='public' AND table_name='contracts' AND column_name='status'`,
    );
    expect(statusCols[0]?.data_type).toBe("text");
  });

  it("has tenant isolation columns on the tenant-scoped tables", async () => {
    if (!client) return;
    const tenantScoped = [
      "contracts",
      "sample_receipts",
      "samples",
      "test_records",
      "audit_events",
      "inspection_brands",
      "inspection_models",
      "inspection_specs",
      "inspection_grades",
      "inspection_technical_requirements",
    ];
    for (const table of tenantScoped) {
      const { rows } = await client.query<{ is_nullable: string; column_default: string }>(
        `SELECT is_nullable, column_default FROM information_schema.columns
         WHERE table_schema='public' AND table_name=$1 AND column_name='tenant_id'`,
        [table],
      );
      expect(rows, `${table}.tenant_id`).toHaveLength(1);
      expect(rows[0].is_nullable).toBe("NO");
    }
  });

  it("enforces per-tenant business code uniqueness", async () => {
    if (!client) return;
    const { rows } = await client.query<{ indexname: string }>(
      `SELECT indexname FROM pg_indexes WHERE schemaname='public'
       AND indexname IN ('idx_contracts_tenant_code','idx_receipts_tenant_commission',
                         'idx_brands_tenant_code','idx_models_tenant_code',
                         'idx_specs_tenant_code','idx_grades_tenant_code')`,
    );
    expect(rows).toHaveLength(6);
  });

  it("keeps the junction tables with composite primary keys", async () => {
    if (!client) return;
    const junctions = [
      "inspection_specialty_objects",
      "inspection_standard_parameters",
      "inspection_object_parameters",
      "inspection_object_standards",
      "inspection_object_report_names",
      "inspection_report_name_standards",
      "inspection_report_name_parameters",
      "inspection_param_interface_links",
      "inspection_calculation_methods",
      "inspection_technical_requirements",
    ];
    for (const table of junctions) {
      const { rows } = await client.query<{ constraint_name: string }>(
        `SELECT constraint_name FROM information_schema.table_constraints
         WHERE table_schema='public' AND table_name=$1 AND constraint_type='PRIMARY KEY'`,
        [table],
      );
      expect(rows, `${table} PK`).toHaveLength(1);
    }
    // 历史遗留约束名（V013/V017 改名未同步），与 lab_dev 实测一致
    const { rows: legacy } = await client.query<{ conname: string }>(
      `SELECT conname FROM pg_constraint
       WHERE conname IN ('param_interfaces_pkey','inspection_calculation_rules_pkey')`,
    );
    expect(legacy.map((r) => r.conname)).toEqual(
      expect.arrayContaining(["param_interfaces_pkey", "inspection_calculation_rules_pkey"]),
    );
  });

  it("cascades receipt deletion through samples and test records", async () => {
    if (!client) return;
    const receiptId = "replay-receipt-1";
    const contractId = "replay-contract-1";
    const sampleId = "replay-sample-1";

    await client.query(
      `INSERT INTO contracts (id, contract_code, client_unit, project_name, construction_unit, witness_unit, witness, created_at, updated_at, tenant_id)
       VALUES ($1,'RC-1','c','p','b','w','w','','','t-replay')`,
      [contractId],
    );
    // category_code 有真 FK（receipts_category_fk → inspection_report_names.code），先造父行
    await client.query(
      `INSERT INTO inspection_report_names (code, name, created_at, updated_at)
       VALUES ('rn-1','replay-report','','')`,
    );
    // parameter_code 有真 FK（testrec_param_fk → inspection_parameters.code），先造父行
    await client.query(
      `INSERT INTO inspection_parameters (code, name, raw_name, canonical_name, created_at, updated_at)
       VALUES ('req','replay-param','replay-param','replay-param','','')`,
    );
    await client.query(
      `INSERT INTO sample_receipts (id, contract_id, commission_code, commission_date, category_code, received_by, sample_source, test_category, created_at, updated_at, tenant_id)
       VALUES ($1,$2,'CM-1','2026-09-13','rn-1','op','client','cat','','','t-replay')`,
      [receiptId, contractId],
    );
    await client.query(
      `INSERT INTO samples (id, receipt_id, sample_code, ext, created_at, updated_at, tenant_id)
       VALUES ($1,$2,'S-1','{}','','','t-replay')`,
      [sampleId, receiptId],
    );
    await client.query(
      `INSERT INTO test_records (id, sample_id, parameter_code, requirement, result, created_at, updated_at, tenant_id)
       VALUES ('replay-tr-1',$1,'req','r','5','','','t-replay')`,
      [sampleId],
    );

    await client.query("DELETE FROM sample_receipts WHERE id = $1", [receiptId]);

    const { rowCount } = await client.query(
      "SELECT 1 FROM samples WHERE id = $1 UNION ALL SELECT 1 FROM test_records WHERE id = $2",
      [sampleId, "replay-tr-1"],
    );
    expect(rowCount).toBe(0);
  });
});
