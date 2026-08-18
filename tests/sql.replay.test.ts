// SQL replay test：把 shared/sql/migrations/V001..V014 顺序跑一遍，断言 schema 一致。
//
// 依赖：borrows pg driver from output/lab-management-system-nextjs/node_modules/pg
// （shared 仓自身禁 npm runtime 依赖，见 ADR-0007）。
//
// 跳过条件：环境变量 PG_REPLAY_SKIP=1（CI 默认跑；本地开发无 PG 时可跳）。

import { describe, it, expect, beforeAll } from "vitest";
import { createRequire } from "node:module";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readdirSync, readFileSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");
const MIGRATIONS_DIR = resolve(SHARED_ROOT, "sql/migrations");

// pg 模块本地 stub（避免引入 @types/pg 作为 devDep；shared 仓禁 npm deps）
// 仅声明本测试用到的最小 surface
type PgClient = {
  connect(): Promise<void>;
  query<R = unknown>(sql: string, params?: unknown[]): Promise<{ rows: R[]; rowCount: number }>;
  end(): Promise<void>;
};

// 从 lab-nextjs 借 pg（与 scripts/create-pg-databases.mjs 同样套路）
const labNextjsRoot = resolve(SHARED_ROOT, "../lab-management-system-nextjs");
const requireFromLab = createRequire(resolve(labNextjsRoot, "package.json"));
let pgModule: { Client: new (cfg: unknown) => PgClient } | null = null;
try {
  pgModule = requireFromLab("pg") as { Client: new (cfg: unknown) => PgClient };
} catch {
  // 借不到就不跑（lab-nextjs 未 npm install）
}

const PG_HOST = process.env.PG_HOST ?? "100.79.128.25";
const PG_PORT = Number(process.env.PG_PORT ?? 5432);
const PG_USER = process.env.PG_USER ?? "postgres";
const PG_PASSWORD = process.env.PG_PASSWORD ?? "qiand68+++";
const PG_DATABASE = process.env.PG_DATABASE_TEST ?? "lab_test";

const EXPECTED_TABLES = [
  "contracts",
  "sample_receipts",
  "samples",
  "test_records",
  "inspection_brands",
  "inspection_models",
  "inspection_specs",
  "inspection_grades",
  "inspection_technical_requirements",
  "audit_events",
  "inspection_specialties",
  "inspection_objects",
  "inspection_parameters",
  "inspection_standards",
  "inspection_specialty_objects",
  "inspection_object_parameters",
  "inspection_object_standards",
  "inspection_standard_parameters",
  "inspection_report_names",
  "inspection_object_report_names",
  "inspection_report_name_standards",
  "inspection_report_name_parameters",
  "inspection_calculation_rules",
  "inspection_param_interfaces",
  "inspection_param_interface_links",
];

const EXPECTED_ENUMS = [
  // V014 把 12 个 enum 转 TEXT + DROP TYPE；仅 audit_action 仍为 PG enum（V006 引入，
  // 暂未被 springboot 端 AuditEvent 接入，未来 audit 端点落地时再单独迁移）。
  "audit_action",
];

describe("SQL migrations replay", () => {
  if (!pgModule || process.env.PG_REPLAY_SKIP === "1") {
    it.skip("pg driver not available or PG_REPLAY_SKIP=1", () => {});
    return;
  }

  let client: PgClient | null = null;

  beforeAll(async () => {
    client = new pgModule.Client({
      host: PG_HOST,
      port: PG_PORT,
      user: PG_USER,
      password: PG_PASSWORD,
      database: PG_DATABASE,
      connectionTimeoutMillis: 5000,
    });
    await client.connect();

    // 清空 public schema，让 V001..V007 从零跑
    await client.query("DROP SCHEMA IF EXISTS public CASCADE");
    await client.query("CREATE SCHEMA public");
    await client.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');

    // 跑 V001..V007（按文件名字典序）
    const files = readdirSync(MIGRATIONS_DIR)
      .filter((f) => /^V\d+__.*\.sql$/.test(f))
      .sort();
    for (const f of files) {
      const sql = readFileSync(resolve(MIGRATIONS_DIR, f), "utf-8");
      await client.query(sql);
    }
  }, 30000);

  it("creates 25 expected tables", async () => {
    if (!client) return;
    const { rows } = await client.query<{ table_name: string }>(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name",
    );
    const tables = rows.map((r: { table_name: string }) => r.table_name);
    for (const expected of EXPECTED_TABLES) {
      expect(tables, `missing table: ${expected}`).toContain(expected);
    }
  });

  it("creates 1 expected enum types (audit_action; rest converted to TEXT by V014)", async () => {
    if (!client) return;
    const { rows } = await client.query<{ typname: string }>(
      "SELECT typname FROM pg_type WHERE typtype = 'e' ORDER BY typname",
    );
    const enums = rows.map((r: { typname: string }) => r.typname);
    for (const expected of EXPECTED_ENUMS) {
      expect(enums, `missing enum: ${expected}`).toContain(expected);
    }
    // 验证其他 12 个 enum 全部 DROP
    expect(enums.length).toBe(EXPECTED_ENUMS.length);
  });

  it("sample_receipts has jsonb columns", async () => {
    if (!client) return;
    const { rows } = await client.query<{ column_name: string; data_type: string }>(
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'sample_receipts' AND column_name IN ('judgment_basis', 'flow_history')",
    );
    const byCol = new Map(rows.map((r) => [r.column_name, r.data_type]));
    expect(byCol.get("judgment_basis")).toBe("jsonb");
    expect(byCol.get("flow_history")).toBe("jsonb");
  });

  it("contracts has unique commission_code constraint (sample_receipts)", async () => {
    if (!client) return;
    const { rows } = await client.query<{ constraint_name: string }>(
      "SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = 'sample_receipts' AND constraint_type = 'UNIQUE'",
    );
    const names = rows.map((r: { constraint_name: string }) => r.constraint_name);
    expect(names).toContain("sample_receipts_commission_code_unique");
  });

  it("FK cascade works: sample_receipt deletion removes samples", async () => {
    if (!client) return;
    // 插入测试数据：contract + receipt + sample
    await client.query(
      "INSERT INTO contracts (id, contract_code, client_unit, project_name, construction_unit, witness_unit, witness, status) VALUES ('c-1', 'HT-1', '委托方', '项目', '施工单位', '见证单位', '张三', 'active')",
    );
    // 先插报告名称，使 sample_receipts.category_code FK 可过
    await client.query(
      "INSERT INTO inspection_report_names (code, name, sort_order) VALUES ('CAT-1', '测试类别', 0)",
    );
    await client.query(
      "INSERT INTO sample_receipts (id, contract_id, commission_code, commission_date, category_code, received_by, sample_source, test_category) VALUES ('r-1', 'c-1', 'WS-1', '2026-01-01', 'CAT-1', '收样员', '现场', '常规')",
    );
    await client.query(
      "INSERT INTO samples (id, receipt_id, sample_code) VALUES ('s-1', 'r-1', 'YP-1')",
    );

    // 删除 receipt；FK ON DELETE CASCADE 应级联清掉 sample
    await client.query("DELETE FROM sample_receipts WHERE id = 'r-1'");

    const { rowCount } = await client.query<{}>(
      "SELECT 1 FROM samples WHERE id = 's-1'",
    );
    expect(rowCount).toBe(0);
  });

  // afterAll：清理连接
  // vitest 默认 afterAll 不在 describe 内 import；这里用 process.on('exit') 兜底
});