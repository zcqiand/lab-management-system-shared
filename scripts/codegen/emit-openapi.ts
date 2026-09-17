// Emit OpenAPI 3.1 from TypeSpec SSOT
import { execSync } from "node:child_process";
import { resolve } from "node:path";
import { mkdirSync, existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";

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

// ============================================================
// fuzz:skip 注释 → openapi.yaml x-fuzz 扩展映射（ADR-0036 / Phase E）
//
// TypeSpec 的 @typespec/openapi3 emitter 默认丢弃用户自定义装饰器，
// 且 `extern dec` 必须配 JS runtime hook（@typespec/compiler 硬规则），
// 引入自定义装饰器等于拉一套 JS 插件，性价比低。改用注释锚点：
//
//   // fuzz:skip   ← 标记该 op 跳过 Schemathesis 模糊测试
//   op someEndpoint(...): ...;
//
// emit 后处理：grep tsp/routes/*.tsp 找 `// fuzz:skip` 行，向上 6 行内找
// op-level @route("...") 拼接 service-level + namespace-level @route 得完整 path，
// 在 generated/openapi.yaml 对应 path 下注入 x-fuzz: skip vendor 扩展。
// 4 后端 codegen 默认忽略 x- 前缀字段（openapi-generator-csharp / NSwag /
// openapi-generator-java 均验证），业务类型零污染。
// ============================================================

const routesDir = resolve(root, "tsp/routes");
const openapiPath = resolve(root, "generated/openapi/openapi.yaml");

// 1. 收集 service-level @route（main.tsp namespace 顶部）
let serviceRoute = "";
try {
  const mainContent = readFileSync(resolve(root, "main.tsp"), "utf-8");
  for (const line of mainContent.split("\n")) {
    const m = line.match(/^\s*@route\("([^"]+)"\)/);
    if (m) serviceRoute = m[1];
  }
} catch {
  /* main.tsp 不存在或读不到 → 不拼前缀 */
}

// 2. 收集每个 route 文件 namespace + op // fuzz:skip
//
// nsRoute 算法：找 `namespace` 关键字前最近的 @route 行（namespace 顶部装饰器）。
// opRoute 算法：从 // fuzz:skip 向上 6 行内找最近的 @route 行。
// fullPath = serviceRoute + nsRoute + opRoute（TypeSpec namespace 嵌套继承语义）。
const fuzzSkip = new Set<string>();
if (existsSync(routesDir)) {
  for (const file of readdirSync(routesDir).filter((f) => f.endsWith(".tsp"))) {
    const lines = readFileSync(resolve(routesDir, file), "utf-8").split("\n");
    let nsRoute = "";
    for (let i = 0; i < lines.length; i++) {
      // 找 namespace 关键字前的 @route（namespace 顶部装饰器）
      if (lines[i].match(/^\s*namespace\s+/)) {
        for (let j = i - 1; j >= 0; j--) {
          const m = lines[j].match(/^\s*@route\("([^"]+)"\)/);
          if (m) { nsRoute = m[1]; break; }
          // 遇到非装饰器行（如 model / op）停止向上
          if (lines[j].match(/^\s*(model|op|@service|@route)\b/)) break;
        }
      }
      if (lines[i].match(/^\s*\/\/\s*fuzz:skip\s*$/)) {
        let opRoute = "";
        // 向上 6 行内找 op-level @route（// fuzz:skip 紧贴在 op 上方）
        for (let j = i - 1; j >= Math.max(0, i - 6); j--) {
          const m = lines[j].match(/^\s*@route\("([^"]+)"\)/);
          if (m) { opRoute = m[1]; break; }
        }
        const fullPath = serviceRoute + nsRoute + opRoute;
        fuzzSkip.add(fullPath);
      }
    }
  }
}

// 3. openapi.yaml 注入 x-fuzz: skip（path 级 vendor 扩展，作用于该 path 下所有 method）
if (existsSync(openapiPath) && fuzzSkip.size > 0) {
  let content = readFileSync(openapiPath, "utf-8");
  let injected = 0;
  let missing = 0;
  for (const path of fuzzSkip) {
    const escaped = path.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    // openapi.yaml 标准格式：path 在 2 空格缩进（顶层 key），method 在 4 空格缩进
    const pathRegex = new RegExp(`(\\n|^)(  ${escaped}):\\s*\\n`, "m");
    if (pathRegex.test(content)) {
      content = content.replace(
        pathRegex,
        `$1$2:\n    x-fuzz: skip\n`,
      );
      injected++;
    } else {
      console.warn(`[emit-fuzz] WARN: fuzz:skip declared at path "${path}" but not found in openapi.yaml — 检查 @route 拼接或 namespace 嵌套`);
      missing++;
    }
  }
  if (injected > 0 || missing > 0) {
    writeFileSync(openapiPath, content);
    console.log(`[emit-fuzz] injected x-fuzz on ${injected} paths, ${missing} missing`);
  }
}