// tests/templates-parity.test.ts — 消费位模板副本与 shared 单源哈希一致（V016 根治）。
// sync-templates.mjs --check 退出码 0 = 四消费位与 assets/templates 逐字节一致；
// 子进程 exit 1 时 execFileSync 抛错——正是想要的 FAIL 行为，stdout 带出全部 drift 明细。
// （注意 --check 分支在 exit 前不打印「全部一致」，故断言「不抛错」而非断言 stdout 内容。）
import { describe, it, expect } from "vitest";
import { execFileSync } from "node:child_process";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

describe("templates parity（四消费位 vs shared）", () => {
  it("sync-templates --check 退出码 0", () => {
    try {
      execFileSync(process.execPath, ["scripts/sync-templates.mjs", "--check"], {
        cwd: resolve(__dirname, ".."),
        encoding: "utf8",
      });
    } catch (e) {
      const stdout = (e as { stdout?: string }).stdout ?? String(e);
      throw new Error(`parity --check 退出码非 0（消费位副本与 shared 单源不一致）：\n${stdout}`);
    }
  });
});
