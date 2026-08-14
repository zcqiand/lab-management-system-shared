-- V010__init_param_interfaces.sql
-- M06.F08 参数界面：param_interfaces + param_interface_links。
-- TypeSpec 来源: tsp/models/param-interface.tsp

CREATE TABLE param_interfaces (
    code            text        PRIMARY KEY,
    name            text,
    component_path  text        NOT NULL,
    description     text,
    is_official     boolean,
    sort_order      integer     NOT NULL DEFAULT 0,
    config          jsonb,
    created_at      text        NOT NULL DEFAULT '',
    updated_at      text        NOT NULL DEFAULT ''
);
COMMENT ON TABLE param_interfaces IS '参数界面（M06.F08）。';

CREATE TABLE param_interface_links (
    inspection_parameter_code   text        NOT NULL,
    param_interface_code        text        NOT NULL,
    report_name_code            text,
    config                      jsonb,
    created_at                  text        NOT NULL DEFAULT '',
    updated_at                  text        NOT NULL DEFAULT '',

    PRIMARY KEY (inspection_parameter_code, param_interface_code),

    CONSTRAINT pil_param_fk FOREIGN KEY (inspection_parameter_code)
        REFERENCES inspection_parameters (code) ON DELETE CASCADE,
    CONSTRAINT pil_interface_fk FOREIGN KEY (param_interface_code)
        REFERENCES param_interfaces (code) ON DELETE CASCADE,
    CONSTRAINT pil_report_fk FOREIGN KEY (report_name_code)
        REFERENCES inspection_report_names (code) ON DELETE SET NULL
);

CREATE INDEX idx_pil_param ON param_interface_links (inspection_parameter_code);
