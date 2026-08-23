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
// 优先 $MIGRATIONS_DIR env（runtime container:Dockerfile 把 migrations 拷到
// /lab-management-system-shared/sql/migrations,sync-db.mjs 在 /app/scripts/,
// 默认算法算出的 /app/sql/migrations 不存在）。
// dev 环境从 sibling 仓目录结构推断,通常 <repo>/sql/migrations。
const MIGRATIONS_DIR =
  process.env.MIGRATIONS_DIR ?? resolve(SHARED_ROOT, "sql/migrations");

const INCREMENTAL = process.argv.includes("--incremental");

// ── 1. 借 pg driver ─────────────────────────────────────────────────────────
// 多场景兜底(按优先级):
// 1. /app/node_modules/pg          (runtime container:Dockerfile COPY 全量 node_modules 进 /app)
// 2. ../lab-management-system-nextjs/node_modules/pg  (dev:从 nextjs 仓借 driver,shared 仓禁 runtime 依赖)
// 3. ../saas-identity-platform-nextjs/node_modules/pg   (saas 家族 dev)
let pg;
let pgLoadStrategy = "";
try {
  const requireFromRuntime = createRequire(resolve("/app/node_modules", "pg"));
  pg = requireFromRuntime("pg");
  pgLoadStrategy = "/app/node_modules/pg (runtime container)";
} catch {
  try {
    const nextjsRoot = resolve(SHARED_ROOT, "../lab-management-system-nextjs");
    const requireFromNext = createRequire(resolve(nextjsRoot, "package.json"));
    pg = requireFromNext("pg");
    pgLoadStrategy = "../lab-management-system-nextjs/node_modules/pg (dev)";
  } catch {
    try {
      const saasNextjsRoot = resolve(SHARED_ROOT, "../saas-identity-platform-nextjs");
      const requireFromSaas = createRequire(resolve(saasNextjsRoot, "package.json"));
      pg = requireFromSaas("pg");
      pgLoadStrategy = "../saas-identity-platform-nextjs/node_modules/pg (saas dev)";
    } catch {
      console.error(
        "[sync-db] FATAL: 借不到 pg driver。\n" +
          "  尝试过:/app/node_modules/pg、../lab-management-system-nextjs/node_modules/pg、\n" +
          "  ../saas-identity-platform-nextjs/node_modules/pg。\n" +
          "  运行时镜像应保证 /app/node_modules/pg 存在(Dockerfile COPY 全量 node_modules);\n" +
          "  dev 环境请在 nextjs 仓 `npm install`。",
      );
      process.exit(1);
    }
  }
}
console.log(`[sync-db] pg driver 加载自 ${pgLoadStrategy}`);

// ── 2. 连接配置（env，fallback 到 lab_dev）──────────────────────────────────
// 优先 DATABASE_URL（标准 PG 连接串,ADR-0009）;缺失时回退到 PG_* 单独 env
//（兼容旧 deploy 脚本与 saas 等姊妹仓的 5 段式 env）。
// PG_PASSWORD 需明文未 URL-encoded（DATABASE_URL 里 %2B 是 + 的 encoded 形式）。
const DATABASE_URL = process.env.DATABASE_URL;
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
  "inspection_param_interfaces",
  "inspection_param_interface_links",
];

const EXPECTED_ENUMS = [
  // V014__enums_to_text.sql 后,12 个 PG enum 全部 DROP 改 TEXT（V014 注释：TypeSpec 契约
  // 层兜底 enum 字符串校验,DB 层用 CHECK 约束不强加）。只剩 audit_action 是 PG enum
  // （V006 阶段未被任何 JPA 仓直接使用,保留 PG enum 兼容性）。
  "audit_action",
];

// tracking 表名（双下划线前缀：让它在 \dt 列表里排到最前面，标明是元数据表而非业务表；
// drizzle/prisma 同惯例）
const TRACKING_TABLE = "__schema_migrations";

// ── 3. 执行 ────────────────────────────────────────────────────────────────
// DATABASE_URL 优先(单 string,免 5 段 env 漂移);否则用 PG_* 拼。
const client = new pg.Client(
  DATABASE_URL
    ? { connectionString: DATABASE_URL, connectionTimeoutMillis: 10000 }
    : {
        host: PG_HOST,
        port: PG_PORT,
        user: PG_USER,
        password: PG_PASSWORD,
        database: PG_DATABASE,
        connectionTimeoutMillis: 10000,
      }
);

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
  // 同时检查 tables 和 types（V014 之前 13 个 enum,V014 之后留 audit_action）。
  // 只查 tables 会漏过 types(用户实测 V006 audit_action 残留导致全量重建半路炸)。
  const { rows: existingTables } = await client.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'",
  );
  const { rows: existingTypes } = await client.query(
    "SELECT typname FROM pg_type WHERE typtype IN ('e','c') AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')",
  );
  if (existingTables.length > 0 || existingTypes.length > 0) {
    console.error(
      `[sync-db] ABORT: 目标库非空（${existingTables.length} 张表 + ${existingTypes.length} 个 type）。` +
        " 为防误覆盖，脚本拒绝继续。\n" +
        "  重建请先手动：DROP SCHEMA public CASCADE; CREATE SCHEMA public;\n" +
        "  增量迁移请用：node scripts/sync-db.mjs --incremental",
    );
    process.exit(1);
  }

  console.log(`[sync-db] 发现 ${files.length} 个迁移文件，顺序执行：`);
  // 全量模式同样写 tracking 表（与增量模式同一张 __schema_migrations）：
  // 重建完的库再跑 --incremental 时能直接对账，不依赖冷启动 baseline 猜测。
  await client.query(`
    CREATE TABLE IF NOT EXISTS ${TRACKING_TABLE} (
      version    VARCHAR(255) PRIMARY KEY,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);
  await client.query(`DELETE FROM ${TRACKING_TABLE}`);
  for (const f of files) {
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
