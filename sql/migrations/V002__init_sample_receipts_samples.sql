-- V002__init_sample_receipts_samples.sql
-- 落地 entities: sample_receipts + samples（+ flow_status / receipt_result 枚举）
-- TypeSpec 来源: tsp/models/sample-receipt.tsp SampleReceipt / tsp/models/sample.tsp Sample
-- 业务域: M03 试验过程管理（接样 → 任务分配 → 数据录入 → 审核 → 批准 → 发放 → 归档）

-- 1. 枚举类型
CREATE TYPE flow_status AS ENUM (
    'receiving',
    'task_assignment',
    'data_entry',
    'review',
    'approval',
    'issuance',
    'archived',
    'completed'
);

CREATE TYPE receipt_result AS ENUM (
    'pass',
    'fail',
    ''      -- 未评定（与 backup ReceiptResultEnum 的空串成员对齐）
);

-- 2. 接样单 sample_receipts（M03.F01/F02/F05-F09）
CREATE TABLE sample_receipts (
    id                          text        PRIMARY KEY,
    contract_id                 text        NOT NULL,
    commission_code             text        NOT NULL,
    commission_date             text        NOT NULL,
    commission_register_code    text,
    commission_register_date    text,
    category_code               text        NOT NULL,   -- 逻辑 FK → inspection_report_names（M06，不强制）
    project_name                text,
    client_unit                 text,
    building_unit               text,
    supervisor_unit             text,
    construction_unit           text,
    witness_unit                text,
    sampling_location           text,
    witness                     text,
    witness_phone               text,
    inspector                   text,
    inspector_phone             text,
    received_by                 text        NOT NULL,
    sample_source               text        NOT NULL,
    test_category               text        NOT NULL,
    test_environment            text,
    main_equipment              text,
    test_operator               text,
    test_start_date             text,
    test_end_date               text,
    original_record_no          text,
    remark                      text,
    judgment_basis              jsonb,      -- 判定依据：标准码数组
    testing_basis               jsonb,      -- 检测依据
    test_parameters             jsonb,      -- 检测参数缓存
    flow_status                 flow_status NOT NULL DEFAULT 'receiving',
    flow_history                jsonb       NOT NULL DEFAULT '[]'::jsonb,
    last_submitted_by           text,
    assignee_id                 text,       -- M03.F02 任务分配
    assignee_name               text,
    planned_test_date           text,
    report_code                 text,       -- 报告字段并入接样单
    report_date                 text,
    conclusion                  text,
    result                      receipt_result DEFAULT '',
    issued_at                   timestamptz,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    CONSTRAINT sample_receipts_contract_fk FOREIGN KEY (contract_id)
        REFERENCES contracts (id) ON DELETE RESTRICT,
    CONSTRAINT sample_receipts_commission_code_unique UNIQUE (commission_code)
);

CREATE INDEX idx_sample_receipts_contract ON sample_receipts (contract_id);
CREATE INDEX idx_sample_receipts_flow_status ON sample_receipts (flow_status);
CREATE INDEX idx_sample_receipts_category ON sample_receipts (category_code);

COMMENT ON TABLE sample_receipts IS '接样单（M03.F01-F09）。报告字段已并入。ADR-0007 SQL SSOT。';
COMMENT ON COLUMN sample_receipts.category_code IS '逻辑 FK 到已废弃的 inspection_report_names（M06），不强制';
COMMENT ON COLUMN sample_receipts.flow_history IS 'jsonb 数组：FlowHistoryEntry[]（action/from/to/operator/at/reason）';

-- 3. 样品 samples（M03.F02/F03）
CREATE TABLE samples (
    id                  text        PRIMARY KEY,
    receipt_id          text        NOT NULL,
    sample_code         text        NOT NULL,
    sample_name         text,
    model               text,       -- 逻辑 FK → inspection_models（M04.F06），不强制
    specification       text,       -- 逻辑 FK → inspection_specs（M04.F07），不强制
    grade               text,       -- 逻辑 FK → inspection_grades（M04.F08），不强制
    brand               text,       -- 逻辑 FK → inspection_brands（M04.F09），不强制
    manufacturer        text,
    structural_part     text,
    represent_quantity  text,
    sample_quantity     text,
    batch_number        text,
    supply_unit         text,
    arrival_date        text,
    sampling_date       text,
    curing_condition    text,
    age                 text,
    ext                 jsonb       NOT NULL DEFAULT '{}'::jsonb,
    remark              text,
    created_at          text        NOT NULL DEFAULT '',
    updated_at          text        NOT NULL DEFAULT '',

    CONSTRAINT samples_receipt_fk FOREIGN KEY (receipt_id)
        REFERENCES sample_receipts (id) ON DELETE CASCADE
);

CREATE INDEX idx_samples_receipt ON samples (receipt_id);

COMMENT ON TABLE samples IS '样品（M03.F02/F03）。model/spec/grade/brand 为逻辑字符串引用。';
