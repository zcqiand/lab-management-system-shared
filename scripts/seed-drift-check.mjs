#!/usr/bin/env node
// scripts/seed-drift-check.mjs — 种子漂移检测（B1 Phase2，spec §7）。
//
// 种子按灌库同款语义（dedupeByPk + SSO mirror）算出「库应有面」，与目标库
// 确定性 dump 逐行 canonical 对比 + information_schema 列集对比：
//   - onlySeed：种子有库无 → 漏灌（种子改了忘了 seed:db）
//   - onlyDb：库有种子无 → 陈旧行（旧链残留 / 手改库）
//   - 列漂移：种子键不在库列 / NOT NULL 无默认列种子缺键 → 灌库必炸
// 不符 exit 1 并列漂移行。seed:db 后必跑（suite runbook 常驻）。
//
// 用法：DATABASE_URL=postgresql://... node scripts/seed-drift-check.mjs
//   SAAS_TENANT_ID 设与否则与灌库同开关（镜像面期望一致）。

import { createRequire } from "node:module";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync, readdirSync, existsSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");
const require = createRequire(resolve(SHARED_ROOT, "package.json"));
const pg = require("pg");
const { dedupeByPk, mirrorTenantRows } = await import("./seed-db.mjs");

const SEEDS_DIR = resolve(SHARED_ROOT, "seeds");

// canonical 行形状（equiv-check.mjs 同款，Task5 等值验证已证 12 表全等）：
// Date→ISO（timestamptz，库面全 53 列 timestamptz 已实证）、jsonb/对象→stringify、其余 String。
const deepSort = (v) => {
  if (Array.isArray(v)) return v.map(deepSort);
  if (v && typeof v === "object" && !(v instanceof Date)) {
    return Object.fromEntries(
      Object.keys(v).sort().map((k) => [k, deepSort(v[k])]),
    );
  }
  return v;
};
// ISO datetime 字符串（种子面）与 Date（pg driver 面）统一归到 toISOString，
// 否则 "2026-01-01T00:00:00Z" ≠ "2026-01-01T00:00:00.000Z" 全表假阳性。
// numeric 列 pg 返回保 scale 字符串（"17.0000"），种子是 JSON number（17）——
// 归一到数字再 String，剥掉 scale 假差。
const ISO_RE = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/;
const NUM_RE = /^-?\d+(\.\d+)?$/;
const canon = (v) => {
  if (v === null || v === undefined) return null;
  if (v instanceof Date) return v.toISOString();
  if (typeof v === "object") return JSON.stringify(deepSort(v));
  if (typeof v === "string" && ISO_RE.test(v)) return new Date(v).toISOString();
  if (typeof v === "string" && NUM_RE.test(v)) return String(Number(v));
  return String(v);
};
const normRow = (r) => {
  const o = {};
  for (const k of Object.keys(r).sort()) o[k] = canon(r[k]);
  return JSON.stringify(o);
};

export function compareRows(seedRows, dbRows) {
  const seedSet = new Set(seedRows.map(normRow));
  const dbSet = new Set(dbRows.map(normRow));
  const onlySeed = [...seedSet].filter((x) => !dbSet.has(x));
  const onlyDb = [...dbSet].filter((x) => !seedSet.has(x));
  return { onlySeed, onlyDb };
}

export function checkColumns(seedKeys, dbCols) {
  // dbCols: Map<col, { nullable, hasDefault }>
  const issues = [];
  for (const k of seedKeys) {
    if (!dbCols.has(k)) issues.push(`种子列 ${k} 不在库列集（灌库必炸，列漂移）`);
  }
  for (const [col, { nullable, hasDefault }] of dbCols) {
    if (!nullable && !hasDefault && !seedKeys.has(col)) {
      issues.push(`库 NOT NULL 无默认列 ${col} 种子缺键（灌库必炸/灌 null）`);
    }
  }
  return issues;
}

function loadSeeds() {
  if (!existsSync(resolve(SEEDS_DIR, "_meta.json"))) {
    throw new Error(`_meta.json not found in ${SEEDS_DIR}`);
  }
  const tables = {};
  for (const file of readdirSync(SEEDS_DIR)) {
    if (file === "_meta.json" || !file.endsWith(".json")) continue;
    tables[file.replace(/\.json$/, "")] = JSON.parse(
      readFileSync(resolve(SEEDS_DIR, file), "utf8"),
    );
  }
  return tables;
}

async function main() {
  const DATABASE_URL = process.env.DATABASE_URL; // 无兜底，缺了就炸
  if (!DATABASE_URL) {
    console.error("[seed-drift-check] DATABASE_URL env required（禁兜底，ADR-0019）");
    process.exit(1);
  }

  const seeds = loadSeeds();
  const ssoTenantId = process.env.SAAS_TENANT_ID;

  const client = new pg.Client({
    connectionString: DATABASE_URL,
    connectionTimeoutMillis: 8000,
  });
  await client.connect();

  // PK introspect（seed-db.mjs 同款查询，去重语义需要）
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

  const drifts = [];
  const tableNames = Object.keys(seeds);
  for (const table of tableNames) {
    if (!pkByTable.has(table)) {
      drifts.push(`${table}: 库无此表或无 PK（种子有 ${seeds[table].length} 行）`);
      continue;
    }
    const colsRes = await client.query(
      `SELECT column_name, is_nullable, column_default
         FROM information_schema.columns
        WHERE table_schema='public' AND table_name=$1`,
      [table],
    );
    const dbCols = new Map(
      colsRes.rows.map((r) => [
        r.column_name,
        { nullable: r.is_nullable === "YES", hasDefault: r.column_default !== null },
      ]),
    );
    const seedKeys = new Set(seeds[table].flatMap((r) => Object.keys(r)));
    for (const issue of checkColumns(seedKeys, dbCols)) {
      drifts.push(`${table}: ${issue}`);
    }

    // 库应有面 = 种子按灌库同款语义（dedupe + mirror）
    let expected = dedupeByPk(table, seeds[table], pkByTable.get(table));
    const mirrored = ssoTenantId ? mirrorTenantRows(table, expected, ssoTenantId) : null;
    if (mirrored) expected = expected.concat(mirrored);

    const { rows: dbRows } = await client.query(`SELECT * FROM "${table}"`);
    const { onlySeed, onlyDb } = compareRows(expected, dbRows);
    if (onlySeed.length > 0) {
      drifts.push(
        `${table}: 漏灌 ${onlySeed.length} 行（种子有库无），首行 ${onlySeed[0].slice(0, 160)}`,
      );
    }
    if (onlyDb.length > 0) {
      drifts.push(
        `${table}: 陈旧 ${onlyDb.length} 行（库有种子无），首行 ${onlyDb[0].slice(0, 160)}`,
      );
    }
  }
  await client.end();

  if (drifts.length > 0) {
    console.error(`[seed-drift-check] ${drifts.length} 处漂移：`);
    for (const d of drifts) console.error(`  ${d}`);
    process.exit(1);
  }
  console.log(
    `drift check: clean — ${tableNames.length} tables, 行面/列集与种子应有面一致（mirror=${ssoTenantId ? "on" : "off"}）`,
  );
}

const isMain =
  process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  main().catch((e) => {
    console.error(e.message);
    process.exit(1);
  });
}
