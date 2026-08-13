-- V003__init_test_records.sql
-- 落地 entities: test_records（单个样品单条检测记录）
-- TypeSpec 来源: tsp/models/test-record.tsp TestRecord
-- 业务域: M03.F03 数据录入

CREATE TABLE test_records (
    id              text        PRIMARY KEY,
    sample_id       text        NOT NULL,
    parameter_code  text        NOT NULL,   -- 逻辑 FK → inspection_parameters（M06，不强制）
    standard_code   text,                    -- 逻辑 FK → inspection_standards（M06，不强制）
    requirement_code text,                   -- 逻辑 FK → inspection_technical_requirements（M04.F05）
    requirement     text        NOT NULL,
    result          text        NOT NULL,
    verdict         text,                    -- 人工改判文本
    created_at      text        NOT NULL DEFAULT '',
    updated_at      text        NOT NULL DEFAULT '',

    CONSTRAINT test_records_sample_fk FOREIGN KEY (sample_id)
        REFERENCES samples (id) ON DELETE CASCADE
);

CREATE INDEX idx_test_records_sample ON test_records (sample_id);

COMMENT ON TABLE test_records IS '检测记录（M03.F03）。parameter/standard 为逻辑 FK 到已废弃 M06，不强制。';
