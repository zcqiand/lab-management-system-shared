// scripts/seed-db.d.ts — seed-db.mjs 的类型声明（L3 tsc 门：tests/seed-db.test.ts
// import 该 .mjs 时无声明即 TS7016）。
export function buildUpsertSql(
  tableName: string,
  rows: Array<Record<string, unknown>>,
  conflictCols: string[],
): { sql: string; params: unknown[] };
