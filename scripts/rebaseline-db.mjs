// scripts/rebaseline-db.mjs — 一次性破坏性 re-baseline（target DDL）
//
// ⚠️ 会 DROP public schema、所有旧表和数据，仅用于明确授权的 dev/test 或运维窗口。
// 生产环境必须同时显式设置 NODE_ENV=production 与 PG_REBASELINE_ALLOW=1。
// 跑之前必须先做全量 JSON 备份（backups/ 目录有先例：lab_dev-backup-20260913.json）。

import { spawnSync } from "node:child_process";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import postgres from "postgres";

const SHARED_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function requireEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} env required`);
  return value;
}

const pgHost = requireEnv("PG_HOST");
const pgPort = requireEnv("PG_PORT");
const pgUser = requireEnv("PG_USER");
const pgPassword = requireEnv("PG_PASSWORD");
const pgDatabase = requireEnv("PG_DATABASE");

if (process.env.NODE_ENV === "production" && process.env.PG_REBASELINE_ALLOW !== "1") {
  console.error(
    "[rebaseline] FATAL: prod 环境必须 PG_REBASELINE_ALLOW=1 才允许跑",
  );
  process.exit(1);
}

const url = `postgresql://${encodeURIComponent(pgUser)}:${encodeURIComponent(pgPassword)}@${pgHost}:${pgPort}/${pgDatabase}`;
const sql = postgres(url, { max: 1, connect_timeout: 5 });

console.log("[rebaseline] 连接:", url.replace(/:[^:@/]+@/, ":***@"));

try {
  console.log("[rebaseline] step 1/3 — DROP SCHEMA public CASCADE");
  await sql.unsafe("DROP SCHEMA IF EXISTS public CASCADE");
  await sql.unsafe("CREATE SCHEMA public");
} finally {
  await sql.end();
}

console.log("[rebaseline] step 2/3 — drizzle-kit migrate（应用 target DDL）");
const r = spawnSync(
  process.platform === "win32" ? "npx.cmd" : "npx",
  ["--no", "drizzle-kit", "migrate", "--config", "drizzle.config.ts"],
  {
    cwd: SHARED_ROOT,
    env: { ...process.env, DATABASE_URL: url },
    stdio: "inherit",
    shell: process.platform === "win32",
  },
);

if (r.status !== 0) {
  console.error(`[rebaseline] FATAL: drizzle-kit migrate 退出 ${r.status}`);
  process.exit(r.status ?? 1);
}

console.log("[rebaseline] step 3/3 — target DDL OK");
console.log("[rebaseline] 下游必须重新 pull / scaffold（nextjs、springboot、aspnetcore、msw）");
