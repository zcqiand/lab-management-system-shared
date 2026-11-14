// scripts/seed-drift-check.d.mts — seed-drift-check.mjs 类型声明（L3 tsc 门）。
export function compareRows(
  seedRows: Array<Record<string, unknown>>,
  dbRows: Array<Record<string, unknown>>,
): { onlySeed: string[]; onlyDb: string[] };
export function checkColumns(
  seedKeys: Set<string>,
  dbCols: Map<string, { nullable: boolean; hasDefault: boolean }>,
): string[];
