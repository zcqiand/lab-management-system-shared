// scripts/sync-templates.mjs — 把 assets/templates 拷到四个消费位；
// --check 只比对不写（哈希级），差异退出码 1。
import { createHash } from "node:crypto";
import { readdirSync, readFileSync, cpSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SRC = resolve(__dirname, "../assets/templates");
// __dirname = shared/scripts，消费仓是 output/ 下的 sibling → 相对前缀 ../../
const CONSUMERS = [
  "../../lab-management-system-react/src/data/templates",
  "../../lab-management-system-vue/src/data/templates",
  "../../lab-management-system-nextjs/src/data/templates",
  "../../lab-management-system-nextjs/public/templates",
].map((p) => ({ rel: p, abs: resolve(__dirname, p) }));

// 副本私有文件白名单：消费位本地生成物（各自 scripts/gen-template-index.mjs 产物），
// 不是 shared 资产、不参与 sync，也不算 drift。新增消费位私有文件时在此登记并注明原因。
const ALLOWED_EXTRA = {
  "../../lab-management-system-react/src/data/templates": ["manifests.ts"],
  "../../lab-management-system-vue/src/data/templates": ["manifests.ts"],
  "../../lab-management-system-nextjs/src/data/templates": ["manifests.ts"],
  "../../lab-management-system-nextjs/public/templates": [],
};

const CHECK = process.argv.includes("--check");
const hash = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");

let drift = false;
for (const { rel, abs: dest } of CONSUMERS) {
  const srcFiles = readdirSync(SRC).filter((f) => !f.endsWith("index.ts"));
  const destFiles = readdirSync(dest);
  const srcSet = new Set(srcFiles);
  const destSet = new Set(destFiles);
  for (const f of srcSet) {
    if (!destSet.has(f) || hash(resolve(SRC, f)) !== hash(resolve(dest, f))) {
      drift = true;
      console.log(`[drift] ${rel}/${f}`);
      if (!CHECK) cpSync(resolve(SRC, f), resolve(dest, f));
    }
  }
  const extraOk = new Set(ALLOWED_EXTRA[rel]);
  for (const f of destSet) {
    if (!srcSet.has(f) && !extraOk.has(f)) { drift = true; console.log(`[extra] ${rel}/${f}`); }
  }
}
if (CHECK) process.exit(drift ? 1 : 0);
console.log(drift ? "[sync-templates] 已刷新（或 --check 发现漂移）" : "[sync-templates] 全部一致");
