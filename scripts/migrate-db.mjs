// scripts/migrate-db.mjs — 替代 sync-db.mjs；调 drizzle-kit migrate 应用迁移到 PG。
//
// 背景（ADR-0025 / ADR-0033 阶段一）：
// - shared 仓是 schema-first 单一真源；本脚本是「从真源直推 PG」入口。
// - 替代原 sync-db.mjs（手写 V 文件 + __schema_migrations tracking）。
// - Drizzle Kit 用内置 __drizzle_migrations 表 tracking，无需手维护。
//
// 用法：
//   PG_DATABASE=lab_dev node scripts/migrate-db.mjs
//   PG_HOST=... PG_PORT=... PG_USER=... PG_PASSWORD=... PG_DATABASE=... node scripts/migrate-db.mjs
//
// 安全：默认 apply drizzle/meta/_journal.json 列出的所有未 apply 迁移；不会 DROP 表。
// 需要重建时用 scripts/rebaseline-db.mjs（破坏性，先备份）。

import { spawnSync } from "node:child_process";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");

// 连接配置必须显式提供，禁止把部署数据库写进脚本（ADR-0019）。
function requireEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} env required`);
  return value;
}

function buildDrizzleKitEnv() {
  const env = { ...process.env };
  if (!env.DATABASE_URL) {
    const host = requireEnv("PG_HOST");
    const port = requireEnv("PG_PORT");
    const user = requireEnv("PG_USER");
    const password = requireEnv("PG_PASSWORD");
    const database = requireEnv("PG_DATABASE");
    env.DATABASE_URL = `postgresql://${encodeURIComponent(user)}:${encodeURIComponent(password)}@${host}:${port}/${database}`;
  }
  return env;
}

async function main() {
  const env = buildDrizzleKitEnv();
  process.env.DATABASE_URL = env.DATABASE_URL;
  console.log(
    `[migrate-db] DATABASE_URL = ${env.DATABASE_URL.replace(/:[^:@]+@/, ":***@")}`,
  );

  // lab 全部主键是 TEXT，无 uuid_generate_v4 依赖，无需 CREATE EXTENSION preamble。

  // drizzle-kit migrate 读 drizzle.config.ts，自动用 PG_* env 拼连接
  const r = spawnSync(
    process.platform === "win32" ? "npx.cmd" : "npx",
    ["--no", "drizzle-kit", "migrate", "--config", "drizzle.config.ts"],
    {
      cwd: SHARED_ROOT,
      env,
      stdio: "inherit",
      shell: process.platform === "win32",
    },
  );

  if (r.status !== 0) {
    console.error(`[migrate-db] FATAL: drizzle-kit migrate 退出 ${r.status}`);
    process.exit(r.status ?? 1);
  }

  console.log("[migrate-db] OK");
}

main().catch((err) => {
  console.error("[migrate-db] FATAL:", err);
  process.exit(1);
});
