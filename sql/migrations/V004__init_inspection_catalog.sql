-- V004__init_inspection_catalog.sql
-- 落地 entities: inspection_brands / inspection_models / inspection_specs / inspection_grades（M04 基础数据码表）
-- TypeSpec 来源: tsp/models/inspection-{brand,model,spec,grade}.tsp
-- 业务域: M04.F06 型号 / F07 规格 / F08 等级 / F09 牌号维护
-- 四张表结构完全一致（code 主键 + name + 可选 inspection_object_code + remark + sort_order + 时间戳）

-- inspection_object_code 为逻辑 FK → inspection_objects（M06 已废弃），不强制约束

CREATE TABLE inspection_brands (
    code                    text        PRIMARY KEY,
    inspection_object_code  text,       -- 逻辑 FK → inspection_objects（M06，不强制）
    name                    text        NOT NULL,
    remark                  text,
    sort_order              integer     NOT NULL DEFAULT 0,
    created_at              text        NOT NULL DEFAULT '',
    updated_at              text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_brands IS '牌号码表（M04.F09）。ADR-0007 SQL SSOT。';

CREATE TABLE inspection_models (
    code                    text        PRIMARY KEY,
    inspection_object_code  text,       -- 逻辑 FK → inspection_objects（M06，不强制）
    name                    text        NOT NULL,
    remark                  text,
    sort_order              integer     NOT NULL DEFAULT 0,
    created_at              text        NOT NULL DEFAULT '',
    updated_at              text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_models IS '型号码表（M04.F06）。列表按检测专项过滤。';

CREATE TABLE inspection_specs (
    code                    text        PRIMARY KEY,
    inspection_object_code  text,       -- 逻辑 FK → inspection_objects（M06，不强制）
    name                    text        NOT NULL,
    remark                  text,
    sort_order              integer     NOT NULL DEFAULT 0,
    created_at              text        NOT NULL DEFAULT '',
    updated_at              text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_specs IS '规格码表（M04.F07）。';

CREATE TABLE inspection_grades (
    code                    text        PRIMARY KEY,
    inspection_object_code  text,       -- 逻辑 FK → inspection_objects（M06，不强制）
    name                    text        NOT NULL,
    remark                  text,
    sort_order              integer     NOT NULL DEFAULT 0,
    created_at              text        NOT NULL DEFAULT '',
    updated_at              text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_grades IS '等级码表（M04.F08）。';

CREATE INDEX idx_inspection_brands_object ON inspection_brands (inspection_object_code);
CREATE INDEX idx_inspection_models_object ON inspection_models (inspection_object_code);
CREATE INDEX idx_inspection_specs_object  ON inspection_specs  (inspection_object_code);
CREATE INDEX idx_inspection_grades_object ON inspection_grades (inspection_object_code);
