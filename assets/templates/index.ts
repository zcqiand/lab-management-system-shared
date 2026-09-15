/**
 * 报告模板 API（ADR 0005 / Plan Phase 0 Task 0.6）
 * 2026-09-15 自 lab-management-system-msw/src/templates 迁入（msw 剔除 Phase 1）
 *
 * 59 套 docx 报告模板入仓（30 个 docx + 29 个 inject.json；`108_砂浆抗压强度检测报告`
 * 无 sidecar —— 与 React/Vue 仓的故意 parity）。
 *
 * 暴露：
 *   - TEMPLATE_PATHS：name → docx 文件名 的静态映射（手写字面量，不在 import 时做 fs IO）
 *   - TemplateName：TEMPLATE_PATHS 的键
 *   - TemplateNotFoundError：未知 name
 *   - TemplateBrowserUnsupportedError：浏览器上下文（Phase 0 node-only）
 *   - readTemplate(name)：node 端读取 bytes + 解析 inject.json
 *
 * Phase 0 限制：本 API 仅 node 端可用。消费仓的浏览器 byte-loading 仍留在各消费仓
 * （各自的 `import.meta.glob` over 各自的 `data/templates/`），Phase 2 再统一。
 */

import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

/**
 * name → docx 文件名的静态映射。
 *
 * 键 = basename（无扩展名），与 React 仓 `MANIFEST_BY_BASENAME` 的自然键一致；
 * RN 码（RN-101 等）住在消费仓的 `inspection-report-name.json`，**不**作为这里的键。
 *
 * 手写字面量（不在 import 时跑 fs.readdirSync）—— 库不能在 import 时做文件系统 IO，
 * 否则 bundler 与测试都会被噎住。drift guard 见
 * `tests/templates/read-template.test.ts`。
 */
export const TEMPLATE_PATHS = {
  "101_水泥检测报告": "101_水泥检测报告.docx",
  "102_钢筋力学性能、工艺性能、重量偏差检测报告":
    "102_钢筋力学性能、工艺性能、重量偏差检测报告.docx",
  "102_钢筋机械连接接头检测报告": "102_钢筋机械连接接头检测报告.docx",
  "102_钢筋焊接接头检测报告": "102_钢筋焊接接头检测报告.docx",
  "103_建设用砂检测报告": "103_建设用砂检测报告.docx",
  "103_建设用碎（卵）石检测报告": "103_建设用碎（卵）石检测报告.docx",
  "103_普通混凝土用砂检测报告": "103_普通混凝土用砂检测报告.docx",
  "103_普通混凝土用碎（卵）石检测报告": "103_普通混凝土用碎（卵）石检测报告.docx",
  "103_轻集料检测报告": "103_轻集料检测报告.docx",
  "104_墙板检测报告": "104_墙板检测报告.docx",
  "104_混凝土瓦检测报告": "104_混凝土瓦检测报告.docx",
  "104_烧结瓦检测报告": "104_烧结瓦检测报告.docx",
  "104_砖检测报告": "104_砖检测报告.docx",
  "104_蒸压加气混凝土砌块检测报告": "104_蒸压加气混凝土砌块检测报告.docx",
  "105_混凝土抗压强度检测报告": "105_混凝土抗压强度检测报告.docx",
  "105_混凝土抗渗性能检测报告": "105_混凝土抗渗性能检测报告.docx",
  "105_混凝土拌合用水检测报告": "105_混凝土拌合用水检测报告.docx",
  "106_混凝土外加剂检测报告": "106_混凝土外加剂检测报告.docx",
  "106_混凝土膨胀剂检测报告": "106_混凝土膨胀剂检测报告.docx",
  "107_矿粉检测报告": "107_矿粉检测报告.docx",
  "107_粉煤灰检测报告": "107_粉煤灰检测报告.docx",
  "108_建筑砂浆检测报告": "108_建筑砂浆检测报告.docx",
  "108_砂浆抗压强度检测报告": "108_砂浆抗压强度检测报告.docx",
  "109_土工击实检测报告": "109_土工击实检测报告.docx",
  "109_土工压实度检测报告（灌砂法）": "109_土工压实度检测报告（灌砂法）.docx",
  "109_土工压实度检测报告（环刀法）": "109_土工压实度检测报告（环刀法）.docx",
  "110_防水卷材检测报告": "110_防水卷材检测报告.docx",
  "110_防水密封材料检测报告": "110_防水密封材料检测报告.docx",
  "110_防水材料检测报告": "110_防水材料检测报告.docx",
  "110_防水涂料检测报告": "110_防水涂料检测报告.docx",
} as const;

/** 受支持的模板名 = TEMPLATE_PATHS 的键。 */
export type TemplateName = keyof typeof TEMPLATE_PATHS;

/** readTemplate 的返回。injectJson 故意松散为 unknown（Phase 0 不与消费仓 GridManifest 耦合）。 */
export interface ReadTemplateResult {
  /** docx 二进制内容。 */
  bytes: Uint8Array;
  /** 解析后的 `<name>.inject.json`；当 sidecar 不存在时为 null（不是错误）。 */
  injectJson: unknown;
}

/** 请求了 TEMPLATE_PATHS 不认识的 name。 */
export class TemplateNotFoundError extends Error {
  constructor(name: string) {
    super(`Template not found: ${name}`);
    this.name = "TemplateNotFoundError";
  }
}

/**
 * 在浏览器上下文中调用 readTemplate。
 * Phase 0：readTemplate 是 node-only；消费仓的浏览器 byte-loading 留在各仓，Phase 2 再统一。
 */
export class TemplateBrowserUnsupportedError extends Error {
  constructor(reason: string) {
    super(
      `readTemplate is node-only in Phase 0 (reason: ${reason}). ` +
        "Consumer browser loading stays in the consumer repo (Phase 2 redesign).",
    );
    this.name = "TemplateBrowserUnsupportedError";
  }
}

const TEMPLATES_DIR = dirname(fileURLToPath(import.meta.url));

/**
 * Node 端读取模板。
 *
 * 行为：
 *  1. `TEMPLATE_PATHS[name]` 未定义 → 抛 `TemplateNotFoundError`。
 *  2. 浏览器上下文（`typeof window !== "undefined"`）→ 抛 `TemplateBrowserUnsupportedError`。
 *  3. 读取 `<templates>/<name>.docx` 为 `Uint8Array`。
 *  4. 若 `<name>.inject.json` 存在，`JSON.parse` 后返回；若不存在（`108_砂浆抗压强度检测报告` 的
 *     documented parity），返回 `injectJson: null`，**不抛错**。
 */
export async function readTemplate(
  name: string,
): Promise<ReadTemplateResult> {
  if (TEMPLATE_PATHS[name as TemplateName] === undefined) {
    throw new TemplateNotFoundError(name);
  }
  if (typeof window !== "undefined") {
    throw new TemplateBrowserUnsupportedError(
      `typeof window !== "undefined"`,
    );
  }
  const docxPath = resolve(TEMPLATES_DIR, TEMPLATE_PATHS[name as TemplateName]);
  const bytes = new Uint8Array(await readFile(docxPath));

  let injectJson: unknown = null;
  const injectPath = resolve(TEMPLATES_DIR, `${name}.inject.json`);
  try {
    injectJson = JSON.parse(await readFile(injectPath, "utf8"));
  } catch (err) {
    // ENOENT（缺 sidecar）是 documented parity，silent null；其它错误重新抛
    if ((err as NodeJS.ErrnoException).code !== "ENOENT") throw err;
  }
  return { bytes, injectJson };
}
