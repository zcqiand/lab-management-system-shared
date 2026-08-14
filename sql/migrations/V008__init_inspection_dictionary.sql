-- V008__init_inspection_dictionary.sql
-- M06 检测能力：检测专项 / 检测项目 / 检测参数 / 检测标准（4 主表）+ 4 junction 表。
-- TypeSpec 来源: tsp/models/inspection-dictionary.tsp
-- 业务域: M06.F01 专项 / F02 项目 / F03 参数 / F04 标准

-- 1. 枚举类型
CREATE TYPE inspection_standard_status AS ENUM (
    'active', 'superseded', 'draft'
);

CREATE TYPE inspection_parameter_source_type AS ENUM (
    'official', 'custom'
);

CREATE TYPE qualification_level AS ENUM (
    'QUALIFIED', 'RESTRICTED'
);

CREATE TYPE inspection_standard_role AS ENUM (
    'TESTING', 'JUDGMENT'
);

-- 2. inspection_specialties 检测专项（M06.F01）
CREATE TABLE inspection_specialties (
    code            text        PRIMARY KEY,
    official_no     text        NOT NULL,
    name            text        NOT NULL,
    is_official     boolean     NOT NULL DEFAULT true,
    enabled         boolean     NOT NULL DEFAULT true,
    sort_order      integer     NOT NULL DEFAULT 0,
    created_at      text        NOT NULL DEFAULT '',
    updated_at      text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_specialties IS '检测专项（M06.F01）。';

-- 3. inspection_objects 检测项目（M06.F02）
CREATE TABLE inspection_objects (
    code                        text        PRIMARY KEY,
    inspection_specialty_code   text        NOT NULL,
    source_project_no           text        NOT NULL,
    source_project_name         text        NOT NULL,
    name                        text        NOT NULL,
    is_optional_for_qualification boolean   NOT NULL DEFAULT false,
    is_official                 boolean     NOT NULL DEFAULT true,
    enabled                     boolean     NOT NULL DEFAULT true,
    sort_order                  integer     NOT NULL DEFAULT 0,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    CONSTRAINT objects_specialty_fk FOREIGN KEY (inspection_specialty_code)
        REFERENCES inspection_specialties (code) ON DELETE RESTRICT
);
COMMENT ON TABLE inspection_objects IS '检测项目（M06.F02）。';

-- 4. inspection_specialty_objects 专项↔项目 junction（M06）
CREATE TABLE inspection_specialty_objects (
    inspection_specialty_code   text        NOT NULL,
    inspection_object_code      text        NOT NULL,
    remark                      text,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_specialty_code, inspection_object_code),

    CONSTRAINT specialty_objects_specialty_fk FOREIGN KEY (inspection_specialty_code)
        REFERENCES inspection_specialties (code) ON DELETE CASCADE,
    CONSTRAINT specialty_objects_object_fk FOREIGN KEY (inspection_object_code)
        REFERENCES inspection_objects (code) ON DELETE CASCADE
);

-- 5. inspection_parameters 检测参数（M06.F03）
CREATE TABLE inspection_parameters (
    code            text        PRIMARY KEY,
    name            text        NOT NULL,
    raw_name        text        NOT NULL,
    canonical_name  text        NOT NULL,
    method_text     text,
    aliases         jsonb       NOT NULL DEFAULT '[]'::jsonb,
    unit            text,
    source_type     inspection_parameter_source_type NOT NULL DEFAULT 'official',
    sort_order      integer     NOT NULL DEFAULT 0,
    created_at      text        NOT NULL DEFAULT '',
    updated_at      text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_parameters IS '检测参数（M06.F03）。';

-- 6. inspection_standards 检测标准（M06.F04）
CREATE TABLE inspection_standards (
    code                text        PRIMARY KEY,
    name                text        NOT NULL,
    version             text,
    status              inspection_standard_status NOT NULL DEFAULT 'active',
    source_document_id  text,
    source_hash         text,
    sort_order          integer     NOT NULL DEFAULT 0,
    created_at          text        NOT NULL DEFAULT '',
    updated_at          text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE inspection_standards IS '检测标准（M06.F04）。code 可含 "/"。';

-- 7. inspection_object_parameters 项目↔参数 junction（M06.F02/F03）
CREATE TABLE inspection_object_parameters (
    inspection_object_code      text        NOT NULL,
    inspection_parameter_code   text        NOT NULL,
    qualification_level         qualification_level NOT NULL DEFAULT 'QUALIFIED',
    source_page                 integer,
    remark                      text,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_object_code, inspection_parameter_code),

    CONSTRAINT obj_params_object_fk FOREIGN KEY (inspection_object_code)
        REFERENCES inspection_objects (code) ON DELETE CASCADE,
    CONSTRAINT obj_params_parameter_fk FOREIGN KEY (inspection_parameter_code)
        REFERENCES inspection_parameters (code) ON DELETE CASCADE
);

-- 8. inspection_object_standards 项目↔标准 junction（role）
CREATE TABLE inspection_object_standards (
    inspection_object_code      text        NOT NULL,
    inspection_standard_code    text        NOT NULL,
    role                        inspection_standard_role NOT NULL,
    remark                      text,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_object_code, inspection_standard_code, role),

    CONSTRAINT obj_std_object_fk FOREIGN KEY (inspection_object_code)
        REFERENCES inspection_objects (code) ON DELETE CASCADE,
    CONSTRAINT obj_std_standard_fk FOREIGN KEY (inspection_standard_code)
        REFERENCES inspection_standards (code) ON DELETE CASCADE
);

-- 9. inspection_standard_parameters 标准↔参数 junction
CREATE TABLE inspection_standard_parameters (
    inspection_standard_code    text        NOT NULL,
    inspection_parameter_code   text        NOT NULL,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_standard_code, inspection_parameter_code),

    CONSTRAINT std_param_standard_fk FOREIGN KEY (inspection_standard_code)
        REFERENCES inspection_standards (code) ON DELETE CASCADE,
    CONSTRAINT std_param_parameter_fk FOREIGN KEY (inspection_parameter_code)
        REFERENCES inspection_parameters (code) ON DELETE CASCADE
);

CREATE INDEX idx_objects_specialty ON inspection_objects (inspection_specialty_code);
CREATE INDEX idx_obj_params_object ON inspection_object_parameters (inspection_object_code);
CREATE INDEX idx_obj_params_param ON inspection_object_parameters (inspection_parameter_code);
CREATE INDEX idx_obj_std_object ON inspection_object_standards (inspection_object_code);
CREATE INDEX idx_std_param_standard ON inspection_standard_parameters (inspection_standard_code);
