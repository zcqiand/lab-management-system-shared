-- V005__init_technical_requirements.sql
-- 落地 entities: inspection_technical_requirements（M04.F05 技术要求维护）
-- TypeSpec 来源: tsp/models/technical-requirement.tsp TechnicalRequirement
-- 复合主键 (inspection_object_code, inspection_parameter_code, judgment_standard_code)
-- 注意：M04.F05 的 brand/model/grade/spec 现为 FK 引用 V004 四张码表（真实 FK，非逻辑）

CREATE TYPE requirement_value_type AS ENUM (
    'numeric', 'string', 'range', 'formula', 'manual'
);

CREATE TYPE requirement_comparison AS ENUM (
    '≥', '≤', '=', 'range', 'eq'
);

CREATE TYPE requirement_verification_status AS ENUM (
    'draft', 'reviewed', 'verified', 'rejected'
);

CREATE TYPE requirement_judgment_mode AS ENUM (
    'automatic', 'manual'
);

CREATE TABLE inspection_technical_requirements (
    inspection_object_code      text        NOT NULL,   -- 逻辑 FK → inspection_objects（M06，不强制）
    inspection_parameter_code   text        NOT NULL,   -- 逻辑 FK → inspection_parameters（M06，不强制）
    judgment_standard_code      text        NOT NULL,   -- 逻辑 FK → inspection_standards（M06，不强制）
    conditions                  text,
    value_type                  requirement_value_type NOT NULL DEFAULT 'numeric',
    min_value                   integer,
    max_value                   integer,
    target_value                text,
    expression                  text,
    unit                        text,
    comparison                  requirement_comparison NOT NULL DEFAULT '≥',
    judgment_mode               requirement_judgment_mode NOT NULL DEFAULT 'manual',
    verification_status         requirement_verification_status NOT NULL DEFAULT 'draft',
    clause                      text,
    source_page                 integer,
    source_hash                 text,
    brand                       text,       -- FK 引用 inspection_brands（不强制，码表 code 可为空引用）
    model                       text,       -- FK 引用 inspection_models
    grade                       text,       -- FK 引用 inspection_grades
    spec                        text,       -- FK 引用 inspection_specs
    sieve                       text,       -- 颗粒级配 2D 查表键
    remark                      text,
    sort_order                  integer     NOT NULL DEFAULT 0,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_object_code, inspection_parameter_code, judgment_standard_code),

    CONSTRAINT tech_req_brand_fk FOREIGN KEY (brand)
        REFERENCES inspection_brands (code) ON DELETE SET NULL,
    CONSTRAINT tech_req_model_fk FOREIGN KEY (model)
        REFERENCES inspection_models (code) ON DELETE SET NULL,
    CONSTRAINT tech_req_grade_fk FOREIGN KEY (grade)
        REFERENCES inspection_grades (code) ON DELETE SET NULL,
    CONSTRAINT tech_req_spec_fk FOREIGN KEY (spec)
        REFERENCES inspection_specs (code) ON DELETE SET NULL
);

CREATE INDEX idx_tech_req_object ON inspection_technical_requirements (inspection_object_code);
CREATE INDEX idx_tech_req_parameter ON inspection_technical_requirements (inspection_parameter_code);

COMMENT ON TABLE inspection_technical_requirements IS '技术要求维护（M04.F05）。按四维度匹配样品；brand/model/grade/spec 为 FK 引用 V004 码表。';
