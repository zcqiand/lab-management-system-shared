// tests/seeds-parity.test.ts — 双源共存期漂移防护。
// shared/seeds 是权威源（见 seeds/README.md）；lab-nextjs/src/seeds 是 prod 灌库链
// （seed-from-snapshot.mjs）的消费副本。二者漂移 = prod 灌出的库与测试锚定的种子分叉。
import { describe, it, expect } from "vitest";
import { readdirSync, readFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { resolve, dirname, relative } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SHARED_SEEDS = resolve(__dirname, "../seeds");
const NEXTJS_SEEDS = resolve(__dirname, "../../lab-management-system-nextjs/src/seeds");

const sha = (p: string) =>
  createHash("sha256").update(readFileSync(p)).digest("hex");

describe("seeds 双源漂移防护（shared ↔ lab-nextjs）", () => {
  it("两目录 JSON 文件集合与逐文件 sha256 一致", () => {
    const shared = readdirSync(SHARED_SEEDS).filter((f) => f.endsWith(".json")).sort();
    const nextjs = readdirSync(NEXTJS_SEEDS).filter((f) => f.endsWith(".json")).sort();
    expect(nextjs, "文件集合漂移（lab-nextjs src/seeds ≠ shared/seeds）").toEqual(shared);

    const drifted = shared.filter((f) => sha(resolve(SHARED_SEEDS, f)) !== sha(resolve(NEXTJS_SEEDS, f)));
    expect(
      drifted.map((f) => relative(process.cwd(), resolve(SHARED_SEEDS, f))),
      "内容漂移——改 shared/seeds 必须同 commit 同步 lab-nextjs/src/seeds（双写约定，seeds/README.md）",
    ).toEqual([]);
  });
});
