// tests/templates.test.ts — 模板资产完整性锁。
import { describe, it, expect } from "vitest";
import { readdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { TEMPLATE_PATHS } from "../assets/templates/index.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DIR = resolve(__dirname, "../assets/templates");

describe("assets/templates 完整性", () => {
  it("TEMPLATE_PATHS 覆盖 30 套 docx（+29 sidecar = 59 件资产）", () => {
    expect(Object.keys(TEMPLATE_PATHS).length).toBe(30);
  });
  it("30 docx + 29 inject sidecar，108_砂浆抗压强度 无 sidecar（家族故意 parity）", () => {
    const files = readdirSync(DIR);
    expect(files.filter((f) => f.endsWith(".docx")).length).toBe(30);
    expect(files.filter((f) => f.endsWith(".inject.json")).length).toBe(29);
    expect(files.some((f) => f.startsWith("108_砂浆抗压强度") && f.endsWith(".inject.json"))).toBe(false);
  });
  it("TEMPLATE_PATHS 每个值都指向存在的文件", () => {
    for (const p of Object.values(TEMPLATE_PATHS)) {
      expect(readdirSync(DIR)).toContain(p);
    }
  });
});
