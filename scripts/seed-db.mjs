#!/usr/bin/env node
// scripts/seed-db.mjs — 把 seeds/*.json（DB 快照形状）upsert 到目标 PG。
//
// saas 家族姊妹脚本（saas-identity-platform-shared/scripts/seed-db.mjs）语义为
// TRUNCATE 全量重灌，与本脚本 upsert 幂等不同，改种子语义时两处勿混。
//
// 与 lab-nextjs/scripts/seed-from-snapshot.mjs 的差异（2026-09-15 移植时定）：
//   - SEEDS_DIR = <shared>/seeds（不再读 nextjs src/seeds）
//   - 默认 upsert ON CONFLICT (<PK>) DO UPDATE（可重跑、不动目标库其他行）；
//     冲突列运行时从 information_schema introspect PK 得出——24 表里 20 张
//     inspection_* 的 PK 是 code / 复合列，禁硬编码 (id)；无 PK 的表报错拒灌
//   - --reset 才 TRUNCATE ... RESTART IDENTITY CASCADE（破坏性，需显式要求）
//   - DATABASE_URL 缺失 fail-fast（禁兜底，ADR-0019）
//   - 摘要输出只含表名+行数（确定性，重跑两次输出逐字节一致，供幂等断言）
// 用法：
//   DATABASE_URL=postgresql://...lab_test node scripts/seed-db.mjs
//   DATABASE_URL=... node scripts/seed-db.mjs --dry-run
//   DATABASE_URL=... node scripts/seed-db.mjs --reset

import { createRequire } from "node:module";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync, readdirSync, existsSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");
const require = createRequire(resolve(SHARED_ROOT, "package.json"));
const pg = require("pg");

const DRY_RUN = process.argv.includes("--dry-run");
const RESET = process.argv.includes("--reset");
const SEEDS_DIR = resolve(SHARED_ROOT, "seeds");

export function buildUpsertSql(tableName, rows, conflictCols) {
  if (!Array.isArray(conflictCols) || conflictCols.length === 0) {
    throw new Error(
      `buildUpsertSql(${tableName}): conflictCols required（禁硬编码 (id)；无 PK 表应拒灌）`,
    );
  }
  if (rows.length === 0) return { sql: "", params: [] };
  const cols = Object.keys(rows[0]); // 快照形状同表同列
  const missing = conflictCols.filter((c) => !cols.includes(c));
  if (missing.length > 0) {
    throw new Error(
      `buildUpsertSql(${tableName}): conflictCols [${missing.join(", ")}] not in row columns`,
    );
  }
  const tuples = rows.map(
    (_, i) => `(${cols.map((_, j) => `$${i * cols.length + j + 1}`).join(", ")})`,
  );
  let updates = cols.filter((c) => !conflictCols.includes(c));
  if (updates.length === 0) {
    // 冲突列覆盖全表列（纯 junction 形状）：退化为对首冲突列自赋值 no-op——
    // 仍保 ON CONFLICT DO UPDATE 语义（家族硬规则禁 DO NOTHING）
    updates = [conflictCols[0]];
  }
  return {
    sql:
      `INSERT INTO ${tableName} (${cols.join(", ")})\nVALUES ${tuples.join(", ")}\n` +
      `ON CONFLICT (${conflictCols.join(", ")}) DO UPDATE SET ` +
      updates.map((c) => `${c} = EXCLUDED.${c}`).join(", "),
    params: rows.flatMap((r) => cols.map((c) => r[c])),
  };
}

function loadSnapshot() {
  const metaPath = resolve(SEEDS_DIR, "_meta.json");
  if (!existsSync(metaPath)) {
    throw new Error(`_meta.json not found in ${SEEDS_DIR}; seed snapshot must be placed first`);
  }
  const meta = JSON.parse(readFileSync(metaPath, "utf8"));
  const tables = {};
  for (const file of readdirSync(SEEDS_DIR)) {
    if (file === "_meta.json" || !file.endsWith(".json")) continue;
    const table = file.replace(/\.json$/, "");
    tables[table] = JSON.parse(readFileSync(resolve(SEEDS_DIR, file), "utf8"));
  }
  return { meta, tables };
}

async function main() {
  const DATABASE_URL = process.env.DATABASE_URL; // 无兜底，缺了就炸
  if (!DATABASE_URL) {
    console.error("[seed-db] DATABASE_URL env required（禁兜底，ADR-0019）");
    process.exit(1);
  }

  const { meta, tables } = loadSnapshot();
  console.log(
    `Snapshot: ${meta.table_count} tables / ${meta.total_rows} rows / dumped_at=${meta.dumped_at} / source=${meta.source_db}`,
  );

  const client = new pg.Client({
    connectionString: DATABASE_URL,
    connectionTimeoutMillis: 8000,
  });
  await client.connect();

  const tableNames = Object.keys(tables);
  if (tableNames.length === 0) {
    throw new Error("snapshot has no tables");
  }

  // PK introspect（information_schema 同款手法，FK 拓扑 introspect 的姊妹查询）——
  // upsert 冲突列唯一来源；无 PK 的表报错拒灌（禁 DO NOTHING，也无冲突锚点）
  const pkRes = await client.query(
    `SELECT tc.table_name, kcu.column_name
       FROM information_schema.table_constraints tc
       JOIN information_schema.key_column_usage kcu
         ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      WHERE tc.constraint_type = 'PRIMARY KEY'
        AND tc.table_schema = 'public'
      ORDER BY tc.table_name, kcu.ordinal_position`,
  );
  const pkByTable = new Map();
  for (const r of pkRes.rows) {
    if (!pkByTable.has(r.table_name)) pkByTable.set(r.table_name, []);
    pkByTable.get(r.table_name).push(r.column_name);
  }
  const noPk = tableNames.filter((t) => !pkByTable.has(t));
  if (noPk.length > 0) {
    throw new Error(`tables without PRIMARY KEY, refuse to seed: ${noPk.join(", ")}`);
  }

  // 拓扑排序：parents 先于 children。introspect pg_constraint 找「本表 → 引用的表」
  // 的边，再做 Kahn / DFS topo-sort。默认 upsert 分支也按此序执行，保证 FK 先有父行。
  const fkRes = await client.query(
    `SELECT conrelid::regclass::text AS tbl,
            confrelid::regclass::text AS ref
       FROM pg_constraint
      WHERE contype = 'f'
        AND connamespace = 'public'::regnamespace`,
  );
  const deps = new Map();
  for (const t of tableNames) deps.set(t, new Set());
  for (const r of fkRes.rows) {
    const tbl = r.tbl.replace(/^"|"$/g, "");
    const ref = r.ref.replace(/^"|"$/g, "");
    if (deps.has(tbl) && deps.has(ref) && tbl !== ref) deps.get(tbl).add(ref);
  }
  // DFS topo-sort（带 visited 标记）
  const ordered = [];
  const visiting = new Set();
  const visit = (t) => {
    if (visiting.has(t)) return; // 环就忽略（CASCADE 处理）
    visiting.add(t);
    for (const d of deps.get(t) ?? []) visit(d);
    ordered.push(t);
  };
  for (const t of tableNames) visit(t);
  // ordered 现在是 parent → child 拓扑序；保持与 tableNames 的相对关系
  // （FSM 反向遍历保证这一点）

  // 预扫描：哪些列是 jsonb（pg driver 不会自动把数组/对象转 jsonb 字面量，
  // 需要显式 JSON.stringify 后再传。对象字面量它能处理，array-of-object 不行。）
  const jsonbColsByTable = new Map();
  for (const table of tableNames) {
    const r = await client.query(
      `SELECT column_name FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = $1
          AND data_type = 'jsonb'`,
      [table],
    );
    jsonbColsByTable.set(table, new Set(r.rows.map((x) => x.column_name)));
  }

  if (DRY_RUN) {
    console.log("[dry-run] no writes will be issued");
  } else if (RESET) {
    // TRUNCATE ... RESTART IDENTITY CASCADE — PG 自己按 FK 反向拓扑处理
    const quoted = tableNames.map((t) => `"${t}"`).join(", ");
    console.log(`→ TRUNCATE ${quoted} RESTART IDENTITY CASCADE`);
    await client.query(`TRUNCATE ${quoted} RESTART IDENTITY CASCADE`);
  }

  // upsert：默认分支逐表 buildUpsertSql 执行（幂等，不删目标库快照外的行）
  for (const table of ordered) {
    const rows = tables[table];
    if (rows.length === 0) {
      console.log(`  ${table}: 0 rows (empty in snapshot, skipped)`);
      continue;
    }
    const { sql } = buildUpsertSql(table, rows, pkByTable.get(table));
    const cols = Object.keys(rows[0]);
    const jsonbCols = jsonbColsByTable.get(table) ?? new Set();
    const values = rows.flatMap((r) =>
      cols.map((c) => {
        const v = r[c];
        if (v === null || v === undefined) return null;
        // jsonb：只要不是 string 都 JSON.stringify（pg driver 不会自动做）
        if (jsonbCols.has(c)) {
          return typeof v === "string" ? v : JSON.stringify(v);
        }
        return v;
      }),
    );
    if (DRY_RUN) {
      console.log(`[dry-run] would upsert ${rows.length} rows into ${table}`);
    } else {
      try {
        await client.query(sql, values);
      } catch (e) {
        console.error(`  ✗ ${table}: ${e.message}`);
        console.error(`    sql: ${sql.slice(0, 200)}...`);
        throw e;
      }
      console.log(`  ${table}: ${rows.length} rows upserted`);
    }
  }

  // post-flight：不信中间 exit code，逐表 SELECT count(*) 对账。
  //   --reset：TRUNCATE 后重灌，必须与快照逐表相等；
  //   默认 upsert：不删快照外行，校验 actual >= expected（漏灌才红）。
  if (!DRY_RUN) {
    const mismatches = [];
    for (const table of tableNames) {
      const expected = tables[table].length;
      const { rows } = await client.query(
        `SELECT count(*)::int AS n FROM "${table}"`,
      );
      const actual = Number(rows[0].n);
      const ok = RESET ? actual === expected : actual >= expected;
      if (!ok) {
        mismatches.push(`  ${table}: expected ${RESET ? "=" : ">="} ${expected}, got ${actual}`);
      }
    }
    if (mismatches.length > 0) {
      await client.end();
      throw new Error(`post-flight row count mismatch:\n${mismatches.join("\n")}`);
    }
    console.log(
      `\n✓ done. ${tableNames.length} tables seeded; post-flight count(*) verified against snapshot.`,
    );
  }
  await client.end();
}

// 仅 CLI 直跑时执行（被测试 import 时不连库、不触发 DATABASE_URL fail-fast）
const isMain =
  process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  main().catch((e) => {
    console.error(e.message);
    process.exit(1);
  });
}
