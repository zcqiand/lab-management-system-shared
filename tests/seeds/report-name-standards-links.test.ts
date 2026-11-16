// 报告名称↔标准挂链护栏（REQ-2026-041 §6，先红后绿 2026-11-17）。
// 真源：docs/requirements/REQ-2026-041-report-name-links.md
//   §3 A 组洗链规则 + §4 B 组人裁换挂 + §5 C 组缺口终局 + §6 护栏不变量。
// 两道不变量：
//  ① J 腿 ∈ 所辖对象 obj 链 JUDGMENT 收敛——每条 role=JUDGMENT 挂链的
//    (rn, standard) 必须被该 RN 所辖对象（inspection_object_report_names junction）
//    的 obj 链 JUDGMENT 集合并集背书；J 缺失不触发（缺失≠错挂，C 组缺口
//    {RN-103-5, RN-104-3} 不需要例外条目）。
//  ② T 腿 ∉ verdict 集合 ∖ 白名单——A 组规则的真不变量化：每条 role=TESTING
//    挂链的 standard 必须 ∈ method 集合（40 条，_work/standard-kind-draft.md
//    039 人批件机械内联钉锚，同 039 §8.6 先例）∪ 白名单（3 条混合型，
//    REQ §3：GB/T 50081-2019 / JTG 3430-2020 / JGJ 52-2006）。
// 本测试不挂功能 ID：纯种子不变式守卫（同 nextjs 仓 report-name-judgment-basis
// 同域，J≤1 单值不变式由该仓既有测试守），零树变更零 trace 影响。
import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const here = (rel: string) => resolve(HERE, "../..", rel);

interface LinkRow {
  report_name_code: string;
  inspection_standard_code: string;
  role: string;
}

interface ObjectStandardRow {
  inspection_object_code: string;
  inspection_standard_code: string;
  role: string;
}

interface ObjectReportNameRow {
  inspection_object_code: string;
  report_name_code: string;
}

const load = <T,>(file: string): T[] =>
  JSON.parse(readFileSync(here(`seeds/${file}`), "utf8")) as T[];

const rnStandards = load<LinkRow>("inspection_report_name_standards.json");
const objectStandards = load<ObjectStandardRow>("inspection_object_standards.json");
const objectReportNames = load<ObjectReportNameRow>("inspection_object_report_names.json");

/** code 归一：全角斜杠→半角、去空白、大写（种子码存在 "GB/T 13545 - 2014"
 * 带空格、TB∕T 全角斜杠等拼写漂移，匹配前必须归一）。 */
const norm = (code: string): string =>
  code.replace(/∕/g, "/").replace(/\s/g, "").toUpperCase();

// method 集合（40 条）——机械真源 _work/standard-kind-draft.md（039 人批件
// kind=method 行），逐码内联钉锚；比对前经 norm 归一。
const METHOD_TESTING_STANDARDS: ReadonlySet<string> = new Set(
  [
    "GB/T 10294-2008",
    "GB/T 11969-2020",
    "GB/T 1345-2026",
    "GB/T 1346-2024",
    "GB/T 16777-2008",
    "GB/T 176-2025",
    "GB/T 17671-2021",
    "GB/T 208-2014",
    "GB/T 21839-2008",
    "GB/T 228.1-2021",
    "GB/T 232-2024",
    "GB/T 2419-2005",
    "GB/T 2542-2012",
    "GB/T 2651-2023",
    "GB/T 2653-2008",
    "GB/T 28900",
    "GB/T 28900-2022",
    "GB/T 328.10-2007",
    "GB/T 328.11-2007",
    "GB/T 328.14-2007",
    "GB/T 328.18-2007",
    "GB/T 328.20-2007",
    "GB/T 328.26-2007",
    "GB/T 328.4-2007",
    "GB/T 328.8-2007",
    "GB/T 39693.4-2025",
    "GB/T 4111-2013",
    "GB/T 42901-2023",
    "GB/T 50082-2024",
    "GB/T 50123-2019",
    "GB/T 528-2009",
    "GB/T 531.1-2008",
    "GB/T 8074-2008",
    "GBJ 82-85",
    "JGJ/T 27-2014",
    "JGJ/T 70-2009",
    "JTG 3420-2020",
    "JTG 3432-2024",
    "JTG 3441-2024",
    "SL/T 352-2020",
  ].map(norm),
);

// 白名单（REQ §3）：双链混合型（方法名实锤 + 判定/计算行真实，039 §8.3 同款）。
const WHITELIST_TESTING_STANDARDS: ReadonlySet<string> = new Set(
  ["GB/T 50081-2019", "JTG 3430-2020", "JGJ 52-2006"].map(norm),
);

// RN 所辖对象 junction：rn → objects。
const rnToObjects = new Map<string, string[]>();
for (const r of objectReportNames) {
  const arr = rnToObjects.get(r.report_name_code) ?? [];
  arr.push(r.inspection_object_code);
  rnToObjects.set(r.report_name_code, arr);
}

// obj 链 JUDGMENT 收敛：object → JUDGMENT 标准集合（norm 后）。
const objectJudgmentChains = new Map<string, Set<string>>();
for (const r of objectStandards) {
  if (r.role !== "JUDGMENT") continue;
  const set = objectJudgmentChains.get(r.inspection_object_code) ?? new Set<string>();
  set.add(norm(r.inspection_standard_code));
  objectJudgmentChains.set(r.inspection_object_code, set);
}

// ① 挂账例外（盘点勘误，2026-11-17 机械复核）：RN-105-3（混凝土拌合用水）
// J=GB 55008-2021 在其唯一所辖对象 OBJ-SP01-P5（混凝土及拌合用水）的 junction
// JUDGMENT 链无背书（55008 仅在 OBJ-SP01-P2/P3-细骨料链）——REQ §6「现状 J 腿
// 逐个核过全满足」对此行不成立的勘误。钉锚挂账，拌合用水域覆盖批人裁归一
// （补链 / 换挂 / 删挂三案待裁），本案不改挂链不改 obj 种子。
const JUDGMENT_BACKIN_EXCEPTIONS: ReadonlySet<string> = new Set(
  ["RN-105-3|GB 55008-2021"].map((k) => {
    const [rn, std] = k.split("|");
    return `${rn}|${norm(std!)}`;
  }),
);

describe("REQ-2026-041: 报告名称↔标准挂链护栏", () => {
  it("invariant: every JUDGMENT leg has obj-chain JUDGMENT backin via its report name's objects (missing J does not trigger)", () => {
    const violations: string[] = [];
    for (const r of rnStandards) {
      if (r.role !== "JUDGMENT") continue;
      const key = `${r.report_name_code}|${norm(r.inspection_standard_code)}`;
      if (JUDGMENT_BACKIN_EXCEPTIONS.has(key)) continue;
      const objects = rnToObjects.get(r.report_name_code) ?? [];
      const chain = new Set<string>();
      for (const o of objects) {
        for (const std of objectJudgmentChains.get(o) ?? []) chain.add(std);
      }
      if (!chain.has(norm(r.inspection_standard_code))) {
        violations.push(
          `${r.report_name_code}: ${r.inspection_standard_code}（所辖对象 [${objects.join(", ")}] 链无此 JUDGMENT 背书）`,
        );
      }
    }
    expect(
      violations,
      "以下判定依据挂链没有 obj 链 JUDGMENT 背书（判定依据必须有对象链收敛背书；缺失≠错挂，缺失不触发本条）",
    ).toEqual([]);
  });

  it("invariant: every TESTING leg's standard is a method standard or a whitelist dual-chain standard", () => {
    const allowed = new Set([
      ...METHOD_TESTING_STANDARDS,
      ...WHITELIST_TESTING_STANDARDS,
    ]);
    const violations = rnStandards
      .filter((r) => r.role === "TESTING")
      .filter((r) => !allowed.has(norm(r.inspection_standard_code)))
      .map((r) => `${r.report_name_code}: ${r.inspection_standard_code}`);
    expect(
      violations,
      "以下检验依据挂链是 verdict 产品标准（判定面不该出现在检验依据栏；白名单混合型除外）",
    ).toEqual([]);
  });
});
