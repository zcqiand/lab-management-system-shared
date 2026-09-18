// scripts/sync-templates.mjs — 把 assets/templates 拷到四个消费位；
// --check 只比对不写（哈希级），差异退出码 1。
// 拷贝用 read+write 而非 fs.cpSync：Node 24 Windows 下 cpSync 遇中文文件名
// 直接 exit 9（Invalid Argument）进程崩、无报错输出——2026-09-18 模板漂移
// 「跑同步不生效」的根因。
import { createHash } from "node:crypto";
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
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
  // react/vue 的运行时 docx 服务位（ReportPreviewModal fetch /templates/*），spec §3.1 补锁
  "../../lab-management-system-react/public/templates",
  "../../lab-management-system-vue/public/templates",
].map((p) => ({ rel: p, abs: resolve(__dirname, p) }));

// 副本私有文件白名单：消费位本地生成物（各自 scripts/gen-template-index.mjs 产物），
// 不是 shared 资产、不参与 sync，也不算 drift。新增消费位私有文件时在此登记并注明原因。
const ALLOWED_EXTRA = {
  "../../lab-management-system-react/src/data/templates": ["manifests.ts"],
  "../../lab-management-system-vue/src/data/templates": ["manifests.ts"],
  "../../lab-management-system-nextjs/src/data/templates": ["manifests.ts"],
  "../../lab-management-system-nextjs/public/templates": [],
  "../../lab-management-system-react/public/templates": [],
  "../../lab-management-system-vue/public/templates": [],
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
      if (!CHECK) writeFileSync(resolve(dest, f), readFileSync(resolve(SRC, f)));
    }
  }
  const extraOk = new Set(ALLOWED_EXTRA[rel]);
  for (const f of destSet) {
    if (!srcSet.has(f) && !extraOk.has(f)) { drift = true; console.log(`[extra] ${rel}/${f}`); }
  }
}
if (CHECK) process.exit(drift ? 1 : 0);
console.log(drift ? "[sync-templates] 已刷新（或 --check 发现漂移）" : "[sync-templates] 全部一致");
