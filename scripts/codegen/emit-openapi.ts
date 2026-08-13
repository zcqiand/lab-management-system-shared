// Emit OpenAPI 3.1 from TypeSpec SSOT
import { execSync } from "node:child_process";
import { resolve } from "node:path";
import { mkdirSync, existsSync } from "node:fs";

const root = resolve(import.meta.dirname, "../..");
const outDir = resolve(root, "generated/openapi");
if (!existsSync(outDir)) mkdirSync(outDir, { recursive: true });

console.log("[emit-openapi] compiling TypeSpec → OpenAPI 3.1...");
execSync("npx tsp compile .", { cwd: root, stdio: "inherit" });
console.log("[emit-openapi] OK");