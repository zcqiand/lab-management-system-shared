-- V013__rename_param_interface_tables.sql
--
-- 用户指令（2026-08-14）：M06.F08 两表名加 `inspection_` 前缀，对齐同模块其他表的命名约定。
--   param_interfaces       → inspection_param_interfaces
--   param_interface_links  → inspection_param_interface_links
--
-- 设计考虑：
--   - 不回编辑 V010（家族约定：已发 V 文件不可改）。新 V 文件做 ALTER TABLE RENAME。
--   - 列名（param_interface_code 等）保持不变 —— 它们是业务字段，与所属模块前缀无强耦合，
--     改动会触发大型 msw/前端代码同步变更。用户明确说"表名"，列先不动。
--   - 索引 `idx_pil_param` 由 V010 创建；表名改了后索引也跟着表迁移（Postgres RENAME
--     自动同步索引到新 schema 名），无需手动重命名。
--   - FK 约束名 `pil_interface_fk` / `pil_param_fk` 保留（历史上不影响运行）。
--
-- 同步脚本更新：
--   scripts/sync-db.mjs EXPECTED_TABLES 中
--     "param_interfaces" → "inspection_param_interfaces"
--     "param_interface_links" → "inspection_param_interface_links"

ALTER TABLE param_interfaces      RENAME TO inspection_param_interfaces;
ALTER TABLE param_interface_links RENAME TO inspection_param_interface_links;
