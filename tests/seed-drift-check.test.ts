// tests/seed-drift-check.test.ts — seed-drift-check.mjs 纯函数契约 + 集成冒烟。
// 集成段连库约定与 seed-db.test.ts 同款：DATABASE_URL 必填，缺省 skip。
import { describe, it, expect } from "vitest";
import { execFileSync } from "node:child_process";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_ROOT = resolve(__dirname, "..");

describe("seed-drift-check 纯函数", () => {
  it("compareRows：双向差分（onlySeed=漏灌 / onlyDb=库多余陈旧行）", async () => {
    const { compareRows } = await import("../scripts/seed-drift-check.mjs");
    const seed = [
      { code: "A", name: "a" },
      { code: "B", name: "b" },
    ];
    const db = [
      { code: "A", name: "a" },
      { code: "B", name: "b-changed" }, // 内容漂移
      { code: "C", name: "c" }, // 库多余
    ];
    const { onlySeed, onlyDb } = compareRows(seed, db);
    // 内容漂移 = 双向命中（种子 B 不在库 / 库 B-changed 不在种子）
    expect(onlySeed.map((r) => JSON.parse(r).code)).toEqual(["B"]);
    expect(onlyDb.map((r) => JSON.parse(r).code).sort()).toEqual(["B", "C"]);
  });

  it("compareRows：canonical 语义（键序无关、jsonb 对象深比较）", async () => {
    const { compareRows } = await import("../scripts/seed-drift-check.mjs");
    const seed = [{ code: "A", cfg: { x: 1, y: [2] }, name: "a" }];
    const db = [{ name: "a", code: "A", cfg: { y: [2], x: 1 } }];
    const { onlySeed, onlyDb } = compareRows(seed, db);
    expect(onlySeed).toEqual([]);
    expect(onlyDb).toEqual([]);
  });

  it("checkColumns：种子多列 / NOT NULL 无默认缺键 → 红，可空缺键不红", async () => {
    const { checkColumns } = await import("../scripts/seed-drift-check.mjs");
    const seedKeys = new Set(["id", "ghost_col"]);
    const dbCols = new Map([
      ["id", { nullable: false, hasDefault: false }],
      ["need_me", { nullable: false, hasDefault: false }], // NOT NULL 无默认，种子缺键 → 红
      ["with_def", { nullable: false, hasDefault: true }], // 有默认，缺键不红
      ["maybe", { nullable: true, hasDefault: false }], // 可空，缺键不红
    ]);
    const issues = checkColumns(seedKeys, dbCols);
    expect(issues.some((s) => s.includes("ghost_col"))).toBe(true);
    expect(issues.some((s) => s.includes("need_me"))).toBe(true);
    expect(issues.some((s) => s.includes("with_def"))).toBe(false);
    expect(issues.some((s) => s.includes("maybe"))).toBe(false);
  });
});

describe.skipIf(!process.env.DATABASE_URL)("seed-drift-check 集成（灌后库应 exit 0）", () => {
  it("对刚 seed 完的库跑 drift check → exit 0 无漂移", { timeout: 120_000 }, async () => {
    const run = (args: string[]) =>
      execFileSync(process.execPath, args, {
        cwd: SHARED_ROOT, env: process.env, encoding: "utf8",
      });
    run(["scripts/seed-db.mjs"]); // 先灌（upsert 幂等）
    const out = run(["scripts/seed-drift-check.mjs"]);
    expect(out).toContain("drift check: clean");
  });
});
