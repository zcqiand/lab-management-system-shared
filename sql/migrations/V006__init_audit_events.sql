-- V006__init_audit_events.sql
-- 落地 entities: audit_events（M01.F04/F05 认证 + 全局业务审计）
-- TypeSpec 来源: tsp/models/audit-event.tsp AuditEvent
-- 对称 dev JWT 解码器依赖本表落地认证审计

CREATE TYPE audit_action AS ENUM (
    'login', 'logout', 'create', 'update', 'delete', 'flow', 'export', 'other'
);

CREATE TABLE audit_events (
    id          text        PRIMARY KEY,
    action      audit_action NOT NULL,
    operator    text        NOT NULL,   -- 操作人（用户 id / username）
    target      text        NOT NULL,   -- 目标实体（如 sample_receipts）
    target_id   text,                   -- 目标实体 id
    detail      text,                   -- 详情（文本或 JSON 字符串）
    ip          text,
    at          text        NOT NULL,   -- ISO 时间戳（与 backup text 约定一致）
    created_at  text        NOT NULL DEFAULT '',
    updated_at  text        NOT NULL DEFAULT ''
);

CREATE INDEX idx_audit_events_operator ON audit_events (operator);
CREATE INDEX idx_audit_events_target ON audit_events (target, target_id);
CREATE INDEX idx_audit_events_at ON audit_events (at);

COMMENT ON TABLE audit_events IS '审计事件（M01.F04/F05 认证 + 全局业务审计）。';
