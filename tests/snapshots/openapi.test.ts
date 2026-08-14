// Snapshot test: lock OpenAPI spec output
import { describe, it, expect } from "vitest";
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";

const OPENAPI_PATH = resolve(import.meta.dirname, "../../generated/openapi/openapi.yaml");

describe("OpenAPI snapshot", () => {
  it("emits openapi.yaml with paths", () => {
    expect(existsSync(OPENAPI_PATH)).toBe(true);
    const content = readFileSync(OPENAPI_PATH, "utf-8");
    expect(content).toMatch(/^openapi:\s+3\.0\.0$/m);
    expect(content).toContain("/api/auth/login");
    expect(content).toContain("/api/contracts");
    expect(content).toContain("/api/receipts");
    expect(content).toContain("/api/catalog/brands");
  });

  it("contains all route groups", () => {
    const content = readFileSync(OPENAPI_PATH, "utf-8");
    for (const path of [
      "/api/auth/login",
      "/api/auth/me",
      "/api/auth/switch-tenant",
      "/api/contracts",
      "/api/contracts/{id}",
      "/api/receipts",
      "/api/receipts/{id}",
      "/api/receipts/{id}/task",
      "/api/receipts/{id}/history",
      "/api/receipts/flow",
      "/api/samples",
      "/api/test-records",
      "/api/test-records/{id}/verdict",
      "/api/catalog/brands",
      "/api/catalog/models",
      "/api/catalog/specs",
      "/api/catalog/grades",
      "/api/technical-requirements",
      "/api/summary",
      "/api/summary/stats",
      "/api/inspection/specialties",
      "/api/inspection/objects",
      "/api/inspection/parameters",
      "/api/inspection/standards",
      "/api/inspection/links/specialty-object",
      "/api/report-names",
      "/api/report-names/links/object",
      "/api/calculation-rules",
      "/api/param-interfaces",
      "/api/param-interfaces/links",
    ]) {
      expect(content, `missing path: ${path}`).toContain(path);
    }
  });
});
