# lab 家族种子（权威源）

- 形状：PG 快照（snake_case 列名），源 `lab_dev`（见 _meta.json）
- 灌库入口：scripts/seed-db.mjs（upsert 幂等 / --reset 全量重灌）
- 来源历史：2026-09-15 自 lab-management-system-nextjs/src/seeds 迁入
  （scripts/dump-db.mjs 产物）

## 双源共存期约定（至 msw 剔除 Phase 4 删仓止）

改本目录任何 JSON 的 PR，必须同 commit 改
lab-management-system-msw/src/seeds/ 或 src/fixtures/ 中对应数据
（两处形状不同：此处是 DB 列形状，msw 是 API 形状，按语义对齐不按文件名）。
Phase 4 删 msw 仓后本约定作废，本目录成为唯一源。
