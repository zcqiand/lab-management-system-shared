// scripts/sync-db.mjs — 把 shared/sql/migrations/V001..V### 推到目标 PG 库。
//
// 设计（ADR-0007）：shared/sql/ 是 DB 持久层 SSOT。本脚本是「从 SSOT 直推」入口，
// 不走三仓 gen-shared.sh 中转，便于 dev 期快速重建 / 增量迁移。
//
// pg driver 借用：shared 仓禁 npm runtime 依赖（ADR-0007），从相邻的
// lab-management-system-nextjs/node_modules/pg 借（与 tests/sql.replay.test.ts 同套路）。
//
// 两种模式：
//   默认（全量重建）        库必须为空；按字典序跑全部 V*.sql。防误覆盖。
//   --incremental           基于 __schema_migrations tracking 表只跑未记录的 V 文件；
//                           每个文件包在事务里，成功才记录。适合「加了一个字段」的增量场景。
//                           tracking 表存 public.__schema_migrations（双下划线前缀，排列表首）。
//
// 用法：
//   node scripts/sync-db.mjs                  # 全量重建（默认 lab_dev @ 100.79.128.25）
//   node scripts/sync-db.mjs --incremental    # 增量：只跑没跑过的 V 文件
//   PG_DATABASE=lab_test node scripts/sync-db.mjs --incremental
//   PG_HOST=... PG_PORT=... PG_USER=... PG_PASSWORD=... PG_DATABASE=... node scripts/sync-db.mjs
//
// 安全：默认模式不 DROP SCHEMA——库非空即中止。增量模式不动既有表，只追加新 V。
// 需要真正重建时先手动：DROP SCHEMA public CASCADE; CREATE SCHEMA public;

import { createRequire } from "node:module";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readdirSync, readFileSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");
const MIGRATIONS_DIR = resolve(SHARED_ROOT, "sql/migrations");

const INCREMENTAL = process.argv.includes("--incremental");

// ── 1. 借 nextjs 的 pg driver ──────────────────────────────────────────────
const nextjsRoot = resolve(SHARED_ROOT, "../lab-management-system-nextjs");
let pg;
try {
  const requireFromNext = createRequire(resolve(nextjsRoot, "package.json"));
  pg = requireFromNext("pg");
} catch {
  console.error(
    "[sync-db] FATAL: 借不到 lab-management-system-nextjs/node_modules/pg。\n" +
      "  请先在 nextjs 仓 `npm install`，或在一个装了 pg 的环境运行。",
  );
  process.exit(1);
}

// ── 2. 连接配置（env，fallback 到 lab_dev）──────────────────────────────────
const PG_HOST = process.env.PG_HOST ?? "100.79.128.25";
const PG_PORT = Number(process.env.PG_PORT ?? 5432);
const PG_USER = process.env.PG_USER ?? "postgres";
const PG_PASSWORD = process.env.PG_PASSWORD ?? "qiand68+++";
const PG_DATABASE = process.env.PG_DATABASE ?? "lab_dev";

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
  "param_interfaces",
  "param_interface_links",
];

const EXPECTED_ENUMS = [
  "contract_status",
  "flow_status",
  "receipt_result",
  "requirement_value_type",
  "requirement_comparison",
  "requirement_verification_status",
  "requirement_judgment_mode",
  "audit_action",
  "inspection_standard_status",
  "inspection_parameter_source_type",
  "qualification_level",
  "inspection_standard_role",
  "calculation_algorithm_type",
];

// tracking 表名（双下划线前缀：让它在 \dt 列表里排到最前面，标明是元数据表而非业务表；
// drizzle/prisma 同惯例）
const TRACKING_TABLE = "__schema_migrations";

// ── 3. 执行 ────────────────────────────────────────────────────────────────
const client = new pg.Client({
  host: PG_HOST,
  port: PG_PORT,
  user: PG_USER,
  password: PG_PASSWORD,
  database: PG_DATABASE,
  connectionTimeoutMillis: 10000,
});

try {
  console.log(
    `[sync-db] 模式：${INCREMENTAL ? "增量（基于 tracking 表）" : "全量重建（库须为空）"}`,
  );
  console.log(`[sync-db] 连接 ${PG_HOST}:${PG_PORT}/${PG_DATABASE} ...`);
  await client.connect();
  console.log("[sync-db] 已连接。");

  const files = readdirSync(MIGRATIONS_DIR)
    .filter((f) => /^V\d+__.*\.sql$/.test(f))
    .sort();

  if (!INCREMENTAL) {
    await runFresh(client, files);
  } else {
    await runIncremental(client, files);
  }

  await verify(client);
} catch (err) {
  console.error("\n[sync-db] ERROR:", err.message);
  if (err.position) console.error("  位置（字节）:", err.position);
  process.exit(1);
} finally {
  await client.end().catch(() => {});
}

// ── 全量重建：库必须为空，跑全部 V*.sql ─────────────────────────────────────
async function runFresh(client, files) {
  const { rows: existing } = await client.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'",
  );
  if (existing.length > 0) {
    console.error(
      `[sync-db] ABORT: 目标库非空（${existing.length} 张表）。` +
        " 为防误覆盖，脚本拒绝继续。\n" +
        "  重建请先手动：DROP SCHEMA public CASCADE; CREATE SCHEMA public;\n" +
        "  增量迁移请用：node scripts/sync-db.mjs --incremental",
    );
    process.exit(1);
  }

  console.log(`[sync-db] 发现 ${files.length} 个迁移文件，顺序执行：`);
  for (const f of files) {
    const sql = readFileSync(resolve(MIGRATIONS_DIR, f), "utf-8");
    process.stdout.write(`  ${f} ... `);
    await client.query(sql);
    console.log("OK");
  }
}

// ── 增量：tracking 表记录已跑过的 V，只执行新的 ─────────────────────────────
async function runIncremental(client, files) {
  // 1. 确保 tracking 表存在（Flyway 风格）
  await client.query(`
    CREATE TABLE IF NOT EXISTS ${TRACKING_TABLE} (
      version    VARCHAR(255) PRIMARY KEY,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // 2. 查已记录的
  const { rows: applied } = await client.query(
    `SELECT version FROM ${TRACKING_TABLE}`,
  );
  const appliedSet = new Set(applied.map((r) => r.version));

  // 3. 冷启动 baseline：tracking 空，但库已有业务表 → 假定现有 schema = 全部当前 V 的结果，
  //    把它们全部标记为已应用（不执行 SQL），只留真正新加的 V 去跑。
  //    场景：库之前由「全量 sync-db」或手跑 SQL 建好，现在切到 incremental 增量维护。
  if (appliedSet.size === 0) {
    const { rows: businessTables } = await client.query(
      `SELECT table_name FROM information_schema.tables
       WHERE table_schema = 'public' AND table_name <> '${TRACKING_TABLE}'`,
    );
    if (businessTables.length > 0) {
      console.log(
        `[sync-db] baseline：tracking 空 但库已有 ${businessTables.length} 张业务表，` +
          `将 ${files.length} 个现有 V 文件标记为已应用（不执行 SQL）。`,
      );
      for (const f of files) {
        await client.query(
          `INSERT INTO ${TRACKING_TABLE} (version) VALUES ($1) ON CONFLICT DO NOTHING`,
          [f],
        );
        appliedSet.add(f);
      }
      console.log("[sync-db] baseline 完成。后续只执行新加的 V 文件。");
    }
  }

  // 4. 过滤待执行（按字典序，与全量一致）
  const pending = files.filter((f) => !appliedSet.has(f));
  console.log(
    `[sync-db] tracking 表已记录 ${appliedSet.size} 个，待执行 ${pending.length} 个。`,
  );

  if (pending.length === 0) {
    console.log("[sync-db] 无新迁移，schema 已是最新。");
    return;
  }

  // 4. 每个 pending 文件包在事务里：成功才 INSERT tracking 行
  for (const f of pending) {
    const sql = readFileSync(resolve(MIGRATIONS_DIR, f), "utf-8");
    process.stdout.write(`  ${f} ... `);
    await client.query("BEGIN");
    try {
      await client.query(sql);
      await client.query(`INSERT INTO ${TRACKING_TABLE} (version) VALUES ($1)`, [
        f,
      ]);
      await client.query("COMMIT");
      console.log("OK");
    } catch (err) {
      await client.query("ROLLBACK");
      console.log("FAILED");
      throw new Error(`${f}: ${err.message}`);
    }
  }
}

// ── 验证：12 表 + 9 enum（两种模式共用；仅当期望清单匹配时为「green」）─────
async function verify(client) {
  const { rows: tables } = await client.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name",
  );
  const tableNames = tables
    .filter(
      (r) => r.table_name !== TRACKING_TABLE, // tracking 表不计入业务表
    )
    .map((r) => r.table_name);
  const missingTables = EXPECTED_TABLES.filter((t) => !tableNames.includes(t));

  const { rows: enums } = await client.query(
    "SELECT typname FROM pg_type WHERE typtype = 'e' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') ORDER BY typname",
  );
  const enumNames = enums.map((r) => r.typname);
  const missingEnums = EXPECTED_ENUMS.filter((t) => !enumNames.includes(t));

  console.log("\n[sync-db] 验证结果：");
  console.log(`  表：${tableNames.length} 张（期望 ≥ ${EXPECTED_TABLES.length}）`);
  console.log(`  enum：${enumNames.length} 个（期望 ≥ ${EXPECTED_ENUMS.length}）`);

  if (missingTables.length === 0 && missingEnums.length === 0) {
    console.log("\n[sync-db] ✅ 同步成功，schema 与 SSOT 一致。");
  } else {
    if (missingTables.length) console.error("  缺表：" + missingTables.join(", "));
    if (missingEnums.length) console.error("  缺 enum：" + missingEnums.join(", "));
    console.error("\n[sync-db] ❌ 验证失败。");
    process.exit(1);
  }
}
