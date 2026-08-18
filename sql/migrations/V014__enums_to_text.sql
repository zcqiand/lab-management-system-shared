-- V014__enums_to_text.sql
-- 把 12 个 PG 自定义 enum 类型全部转成 TEXT。
-- 原因：Hibernate 6 @Enumerated(STRING) 默认传 enum 常量名（SIMPLE_AVG），与 PG enum
-- 标签小写（simple_avg）不一致，写库失败；@JdbcTypeCode(NAMED_ENUM) 在 Hibernate 6
-- 缺工具支持。各仓 AttributeConverter 显式写 DTO @JsonValue 同款字符串。
-- TypeSpec 契约层不变（DTO enum 仍走 small snake_case 字符串），SSOT 强约束改 SQL CHECK。
--
-- 升级策略：ALTER COLUMN ... TYPE text USING col::text;（PG 会做合法性校验） + DROP TYPE
-- CASCADE（如果后续列无依赖，可保留 PG enum 兼容性；这里选择彻底删 enum，让所有引用
-- 走 TEXT 单路径）。CHECK 约束不强加，由 TypeSpec/OpenAPI enum 兜底校验。
--
-- 12 个 enum 分组：
-- M02/M03 业务表（V001/V002）：contract_status / flow_status / receipt_result
-- M04.F05 技术要求（V005）：requirement_value_type / requirement_comparison /
--   requirement_verification_status / requirement_judgment_mode
-- M06 计算规则（V009）：calculation_algorithm_type
-- M06 字典（V008）：inspection_parameter_source_type / inspection_standard_status /
--   qualification_level / inspection_standard_role
-- V006 audit_action 不在此列（仍是 PG enum，V006 阶段未被任何 JPA 仓直接使用，
-- 保留 PG enum 兼容性；如未来被 springboot 接入再加迁移）。

-- 1. M02 + M03 业务表 3 个 enum
ALTER TABLE contracts
    ALTER COLUMN status TYPE text USING status::text,
    ALTER COLUMN status SET DEFAULT 'active';
DROP TYPE IF EXISTS contract_status CASCADE;

ALTER TABLE sample_receipts
    ALTER COLUMN flow_status TYPE text USING flow_status::text,
    ALTER COLUMN flow_status SET DEFAULT 'receiving';
ALTER TABLE sample_receipts
    ALTER COLUMN result TYPE text USING result::text;
DROP TYPE IF EXISTS flow_status CASCADE;
DROP TYPE IF EXISTS receipt_result CASCADE;

-- 2. M04.F05 技术要求 4 个 enum
ALTER TABLE inspection_technical_requirements
    ALTER COLUMN value_type TYPE text USING value_type::text,
    ALTER COLUMN value_type SET DEFAULT 'numeric';
ALTER TABLE inspection_technical_requirements
    ALTER COLUMN comparison TYPE text USING comparison::text;
ALTER TABLE inspection_technical_requirements
    ALTER COLUMN verification_status TYPE text USING verification_status::text,
    ALTER COLUMN verification_status SET DEFAULT 'draft';
ALTER TABLE inspection_technical_requirements
    ALTER COLUMN judgment_mode TYPE text USING judgment_mode::text,
    ALTER COLUMN judgment_mode SET DEFAULT 'manual';
DROP TYPE IF EXISTS requirement_value_type CASCADE;
DROP TYPE IF EXISTS requirement_comparison CASCADE;
DROP TYPE IF EXISTS requirement_verification_status CASCADE;
DROP TYPE IF EXISTS requirement_judgment_mode CASCADE;

-- 3. M06.F05 计算规则 1 个 enum
ALTER TABLE inspection_calculation_rules
    ALTER COLUMN algorithm_type TYPE text USING algorithm_type::text,
    ALTER COLUMN algorithm_type SET DEFAULT 'manual';
DROP TYPE IF EXISTS calculation_algorithm_type CASCADE;

-- 4. M06 字典 4 个 enum（V008）
ALTER TABLE inspection_parameters
    ALTER COLUMN source_type TYPE text USING source_type::text,
    ALTER COLUMN source_type SET DEFAULT 'official';
ALTER TABLE inspection_standards
    ALTER COLUMN status TYPE text USING status::text,
    ALTER COLUMN status SET DEFAULT 'active';
ALTER TABLE inspection_object_parameters
    ALTER COLUMN qualification_level TYPE text USING qualification_level::text,
    ALTER COLUMN qualification_level SET DEFAULT 'QUALIFIED';
ALTER TABLE inspection_object_standards
    ALTER COLUMN role TYPE text USING role::text;
ALTER TABLE inspection_report_name_standards
    ALTER COLUMN role TYPE text USING role::text;
DROP TYPE IF EXISTS inspection_parameter_source_type CASCADE;
DROP TYPE IF EXISTS inspection_standard_status CASCADE;
DROP TYPE IF EXISTS qualification_level CASCADE;
DROP TYPE IF EXISTS inspection_standard_role CASCADE;
