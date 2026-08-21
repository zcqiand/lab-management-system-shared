// Emit OpenAPI 3.1 from TypeSpec SSOT
import { execSync } from "node:child_process";
import { resolve } from "node:path";
import { mkdirSync, existsSync } from "node:fs";

const root = resolve(import.meta.dirname, "../..");
const outDir = resolve(root, "generated/openapi");
if (!existsSync(outDir)) mkdirSync(outDir, { recursive: true });

// 自举: 消费方 CI fresh clone 拉 shared 但不 install。
// npx tsp 在 node_modules/.bin/ 找不到 tsp 时会去 npm 拉 tsp@0.0.1 (Microsoft 老包,不是 TypeSpec)。
// 这里检测 local tsp 二进制,缺就 npm install (含 devDep: @typespec/* 全套)。
// CLAUDE.md "禁止 npm runtime 依赖"指的是 publish 出来的 package.json;
// emit-openapi.ts 是 build-time 工具,需要 devDep 才能跑。
// 已在 dev 环境跳过此步。
const tspBin = resolve(root, "node_modules/.bin/tsp");
if (!existsSync(tspBin)) {
  console.log("[emit-openapi] bootstrapping shared deps (no @typespec/compiler found)...");
  execSync("npm install --no-audit --no-fund", { cwd: root, stdio: "inherit" });
}

console.log("[emit-openapi] compiling TypeSpec → OpenAPI 3.1...");
execSync("npx tsp compile .", { cwd: root, stdio: "inherit" });
console.log("[emit-openapi] OK");