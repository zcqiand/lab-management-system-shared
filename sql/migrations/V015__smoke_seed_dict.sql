-- V016__smoke_seed_dict.sql
-- B3 smoke 需要的 FK 父行（M06 字典在 dev 未上线，先 seed 1 行 demo）：
-- inspection_specialties 1 行 → 让 contracts.inspection_specialty_code 合法
-- inspection_report_names 1 行 → 让 sample_receipts.category_code 合法
-- 不动 SSOT；本仓 dev-only 一行 filler，后续 M06 上线由 V011/V012 等迁移覆盖时删除。

INSERT INTO inspection_specialties (code, official_no, name, sort_order, created_at, updated_at)
VALUES ('SP-SMK-001', 'OFFICIAL-SMK-001', '专项 smoke 域', 0, '2026-08-18', '2026-08-18')
ON CONFLICT (code) DO NOTHING;

INSERT INTO inspection_report_names (code, name, sort_order, created_at, updated_at)
VALUES ('CAT-SMK-001', '报告类别 smoke', 0, '2026-08-18', '2026-08-18')
ON CONFLICT (code) DO NOTHING;
