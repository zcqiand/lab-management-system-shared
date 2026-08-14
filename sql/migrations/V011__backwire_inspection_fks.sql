-- V011__backwire_inspection_fks.sql
-- M06 回来后，把之前因 M06 缺失而降级为「逻辑 text」的列接回真实 FOREIGN KEY。
-- 不改老 V 文件，用 ALTER TABLE ADD CONSTRAINT 补。
-- 策略：业务表引用码表用 ON DELETE SET NULL / RESTRICT（码表是字典，不该轻易删）。

-- 1. contracts.inspection_specialty_code → inspection_specialties
ALTER TABLE contracts
    ADD CONSTRAINT contracts_specialty_fk
    FOREIGN KEY (inspection_specialty_code) REFERENCES inspection_specialties (code)
    ON DELETE SET NULL;

-- 2. sample_receipts.category_code → inspection_report_names
ALTER TABLE sample_receipts
    ADD CONSTRAINT receipts_category_fk
    FOREIGN KEY (category_code) REFERENCES inspection_report_names (code)
    ON DELETE RESTRICT;

-- 3. test_records.parameter_code → inspection_parameters
ALTER TABLE test_records
    ADD CONSTRAINT testrec_param_fk
    FOREIGN KEY (parameter_code) REFERENCES inspection_parameters (code)
    ON DELETE RESTRICT;

-- 4. test_records.standard_code → inspection_standards
ALTER TABLE test_records
    ADD CONSTRAINT testrec_standard_fk
    FOREIGN KEY (standard_code) REFERENCES inspection_standards (code)
    ON DELETE SET NULL;

-- 5. inspection_technical_requirements（M06.F06，原 M04.F05）补 3 个真实 FK
ALTER TABLE inspection_technical_requirements
    ADD CONSTRAINT tech_req_object_fk
    FOREIGN KEY (inspection_object_code) REFERENCES inspection_objects (code)
    ON DELETE CASCADE;

ALTER TABLE inspection_technical_requirements
    ADD CONSTRAINT tech_req_parameter_fk
    FOREIGN KEY (inspection_parameter_code) REFERENCES inspection_parameters (code)
    ON DELETE CASCADE;

ALTER TABLE inspection_technical_requirements
    ADD CONSTRAINT tech_req_judgment_standard_fk
    FOREIGN KEY (judgment_standard_code) REFERENCES inspection_standards (code)
    ON DELETE RESTRICT;

-- 6. inspection_brands/models/specs/grades.inspection_object_code → inspection_objects
ALTER TABLE inspection_brands
    ADD CONSTRAINT brands_object_fk
    FOREIGN KEY (inspection_object_code) REFERENCES inspection_objects (code)
    ON DELETE SET NULL;
ALTER TABLE inspection_models
    ADD CONSTRAINT models_object_fk
    FOREIGN KEY (inspection_object_code) REFERENCES inspection_objects (code)
    ON DELETE SET NULL;
ALTER TABLE inspection_specs
    ADD CONSTRAINT specs_object_fk
    FOREIGN KEY (inspection_object_code) REFERENCES inspection_objects (code)
    ON DELETE SET NULL;
ALTER TABLE inspection_grades
    ADD CONSTRAINT grades_object_fk
    FOREIGN KEY (inspection_object_code) REFERENCES inspection_objects (code)
    ON DELETE SET NULL;
