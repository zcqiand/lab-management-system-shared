// tests/seed-db.test.ts — seed-db.mjs 契约测试。
// 连库约定与 tests/drizzle.replay.test.ts 同款：DATABASE_URL 必填 fail-fast。
import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");
const require = createRequire(resolve(SHARED_ROOT, "package.json"));

describe("seed-db buildUpsertSql", () => {
  it("code 冲突列表生成 ON CONFLICT (code) DO UPDATE（禁 DO NOTHING）", async () => {
    const { buildUpsertSql } = await import("../scripts/seed-db.mjs");
    const { sql } = buildUpsertSql(
      "inspection_brands",
      [{ code: "BR-1", name: "b", tenant_id: "TENANT-001" }],
      ["code"],
    );
    expect(sql).toContain("ON CONFLICT (code) DO UPDATE");
    expect(sql).not.toContain("DO NOTHING");
    expect(sql).toMatch(/^INSERT INTO inspection_brands/);
  });

  it("id 冲突列 + 多行合并为单条批量 INSERT，参数按行展开", async () => {
    const { buildUpsertSql } = await import("../scripts/seed-db.mjs");
    const { sql, params } = buildUpsertSql(
      "tenants",
      [
        { id: "T1", name: "a" },
        { id: "T2", name: "b" },
      ],
      ["id"],
    );
    expect(sql).toContain("ON CONFLICT (id) DO UPDATE");
    expect(sql).not.toContain("DO NOTHING");
    expect(sql).toContain("VALUES");
    expect(sql.match(/\(\$/g)!.length).toBe(2);
    expect(params).toEqual(["T1", "a", "T2", "b"]);
  });

  it("冲突列覆盖全列时退化为自赋值 no-op，仍禁 DO NOTHING", async () => {
    const { buildUpsertSql } = await import("../scripts/seed-db.mjs");
    const { sql } = buildUpsertSql("pure_link", [{ a: "1", b: "2" }], ["a", "b"]);
    expect(sql).toContain("ON CONFLICT (a, b) DO UPDATE");
    expect(sql).not.toContain("DO NOTHING");
  });

  it("缺 conflictCols 直接抛错（禁硬编码冲突列，无 PK 表拒灌）", async () => {
    const { buildUpsertSql } = await import("../scripts/seed-db.mjs");
    expect(() =>
      buildUpsertSql("whatever", [{ id: "x" }], undefined as unknown as string[]),
    ).toThrow(/conflictCols/);
    expect(() => buildUpsertSql("whatever", [{ id: "x" }], [])).toThrow(/conflictCols/);
  });

  it("空行集返回空 SQL 不抛错", async () => {
    const { buildUpsertSql } = await import("../scripts/seed-db.mjs");
    const { sql, params } = buildUpsertSql("any_table", [], ["id"]);
    expect(sql).toBe("");
    expect(params).toEqual([]);
  });
});

describe.skipIf(!process.env.DATABASE_URL)("seed-db 集成（lab_test）", () => {
  // 超时 300s：migrate + 两次灌库（单次 ~47s，远程 PG 逐表 round-trip）+ 对账，
  // 全局默认 10s 恒假红（lab-nextjs dev login 同款教训）
  it("upsert 灌库后行数与 _meta.total_rows 一致，且重跑幂等", { timeout: 300_000 }, async () => {
    const { execFileSync } = await import("node:child_process");
    const run = (args: string[]) =>
      execFileSync(process.execPath, ["scripts/seed-db.mjs", ...args], {
        cwd: SHARED_ROOT, env: process.env, encoding: "utf8",
      });
    // 先建表（migrate 幂等；PG_* 五件套由调用方 export，drizzle.config.ts fail-fast）
    execFileSync(process.execPath, ["scripts/migrate-db.mjs"], {
      cwd: SHARED_ROOT, env: process.env,
    });
    const out1 = run([]);
    expect(out1).toContain("inspection_brands");
    const out2 = run([]); // 幂等重跑
    const pg = require("pg");
    const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
    await client.connect();
    // createRequire 锚在 <shared>/package.json，相对路径从 shared 根解析（brief 原文 ../ 是笔误）
    const meta = require("./seeds/_meta.json");
    const { rows } = await client.query(
      "SELECT (SELECT count(*) FROM information_schema.tables WHERE table_schema='public') AS t",
    );
    expect(Number(rows[0].t)).toBeGreaterThanOrEqual(meta.table_count);
    await client.end();
    expect(out1).toEqual(out2); // 幂等：两次输出一致（摘要只含表名+行数，确定性）
  });
});
