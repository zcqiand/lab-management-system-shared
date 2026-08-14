-- V009__init_report_names.sql
-- M06 检测能力：报告名称（M06.F07）+ 3 张 report-name junction 表 + 计算规则（M06.F05）。
-- TypeSpec 来源: tsp/models/report-name.tsp / calculation-rule.tsp
-- 业务域: M06.F05 计算规则 / M06.F07 报告名称

CREATE TYPE calculation_algorithm_type AS ENUM (
    'simple_avg',
    'compressive_strength',
    'flexural_strength',
    'steel_tensile',
    'formula',
    'manual',
    'auto_calc_ratio'
);

-- 1. inspection_report_names 报告名称（M06.F07）
CREATE TABLE inspection_report_names (
    code            text        PRIMARY KEY,
    name            text        NOT NULL,
    full_name       text,
    template_path   text,
    summary_name    text,
    ext_fields      jsonb,
    description     text,
    sort_order      integer     NOT NULL DEFAULT 0,
    created_at      text        NOT NULL DEFAULT '',
    updated_at      text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_report_names IS '报告名称（M06.F07）。categoryCode/报告类别汇总口径。';

-- 2. inspection_object_report_names 项目↔报告名称 junction
CREATE TABLE inspection_object_report_names (
    inspection_object_code  text        NOT NULL,
    report_name_code        text        NOT NULL,
    remark                  text,
    created_at              text        NOT NULL DEFAULT '',
    updated_at              text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_object_code, report_name_code),

    CONSTRAINT obj_rn_object_fk FOREIGN KEY (inspection_object_code)
        REFERENCES inspection_objects (code) ON DELETE CASCADE,
    CONSTRAINT obj_rn_report_fk FOREIGN KEY (report_name_code)
        REFERENCES inspection_report_names (code) ON DELETE CASCADE
);

-- 3. inspection_report_name_standards 报告名称↔标准 junction（role）
CREATE TABLE inspection_report_name_standards (
    report_name_code            text        NOT NULL,
    inspection_standard_code    text        NOT NULL,
    role                        inspection_standard_role NOT NULL,
    remark                      text,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (report_name_code, inspection_standard_code, role),

    CONSTRAINT rn_std_report_fk FOREIGN KEY (report_name_code)
        REFERENCES inspection_report_names (code) ON DELETE CASCADE,
    CONSTRAINT rn_std_standard_fk FOREIGN KEY (inspection_standard_code)
        REFERENCES inspection_standards (code) ON DELETE CASCADE
);

-- 4. inspection_report_name_parameters 报告名称↔参数 junction
CREATE TABLE inspection_report_name_parameters (
    report_name_code            text        NOT NULL,
    inspection_parameter_code   text        NOT NULL,
    remark                      text,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (report_name_code, inspection_parameter_code),

    CONSTRAINT rn_param_report_fk FOREIGN KEY (report_name_code)
        REFERENCES inspection_report_names (code) ON DELETE CASCADE,
    CONSTRAINT rn_param_parameter_fk FOREIGN KEY (inspection_parameter_code)
        REFERENCES inspection_parameters (code) ON DELETE CASCADE
);

-- 5. inspection_calculation_rules 计算规则（M06.F05）复合主键
CREATE TABLE inspection_calculation_rules (
    inspection_object_code      text        NOT NULL,
    inspection_parameter_code   text        NOT NULL,
    testing_standard_code       text,
    report_name_code            text,
    algorithm_type              calculation_algorithm_type NOT NULL DEFAULT 'manual',
    specimen_count              integer     NOT NULL DEFAULT 1,
    formula                     text,
    conditions                  text,
    rounding_rule               text,
    remark                      text,
    sort_order                  integer     NOT NULL DEFAULT 0,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_object_code, inspection_parameter_code),

    CONSTRAINT calc_rule_object_fk FOREIGN KEY (inspection_object_code)
        REFERENCES inspection_objects (code) ON DELETE CASCADE,
    CONSTRAINT calc_rule_parameter_fk FOREIGN KEY (inspection_parameter_code)
        REFERENCES inspection_parameters (code) ON DELETE CASCADE,
    CONSTRAINT calc_rule_standard_fk FOREIGN KEY (testing_standard_code)
        REFERENCES inspection_standards (code) ON DELETE SET NULL,
    CONSTRAINT calc_rule_report_fk FOREIGN KEY (report_name_code)
        REFERENCES inspection_report_names (code) ON DELETE SET NULL
);
COMMENT ON TABLE inspection_calculation_rules IS '计算规则（M06.F05）。';

CREATE INDEX idx_obj_rn_object ON inspection_object_report_names (inspection_object_code);
CREATE INDEX idx_rn_std_report ON inspection_report_name_standards (report_name_code);
CREATE INDEX idx_rn_param_report ON inspection_report_name_parameters (report_name_code);
CREATE INDEX idx_calc_rule_object ON inspection_calculation_rules (inspection_object_code);
