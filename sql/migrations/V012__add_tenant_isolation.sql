-- V012__add_tenant_isolation.sql
-- 多租户隔离：业务数据表加 tenant_id（裸标量，无 FK）。
-- 租户真相源在 saas 身份平台，lab 不建 tenants 表；tenant_id 由后端从 token 的
-- tenant_id claim 注入。M06 检测能力字典（专项/项目/参数/标准/报告名称/计算规则/
-- 参数界面 + junction）是平台级共享字典，不加 tenant_id。
--
-- 同时把原「全局唯一」业务键改为「同租户内唯一」（不同租户可有相同合同号/委托号）。

-- 1. contracts: 加 tenant_id，contract_code 从全局唯一改同租户唯一
ALTER TABLE contracts ADD COLUMN tenant_id text NOT NULL DEFAULT '';
DROP INDEX IF EXISTS idx_contracts_code;
CREATE UNIQUE INDEX idx_contracts_tenant_code ON contracts (tenant_id, contract_code);
CREATE INDEX idx_contracts_tenant ON contracts (tenant_id);

-- 2. sample_receipts: 加 tenant_id，commission_code 从全局唯一改同租户唯一
ALTER TABLE sample_receipts ADD COLUMN tenant_id text NOT NULL DEFAULT '';
ALTER TABLE sample_receipts DROP CONSTRAINT IF EXISTS sample_receipts_commission_code_unique;
CREATE UNIQUE INDEX idx_receipts_tenant_commission ON sample_receipts (tenant_id, commission_code);
CREATE INDEX idx_receipts_tenant ON sample_receipts (tenant_id);

-- 3. samples: 加 tenant_id（跟随 receipt，便于跨表按租户查）
ALTER TABLE samples ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE INDEX idx_samples_tenant ON samples (tenant_id);

-- 4. test_records: 加 tenant_id
ALTER TABLE test_records ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE INDEX idx_test_records_tenant ON test_records (tenant_id);

-- 5. M04 四码表（brand/model/spec/grade）：加 tenant_id，code 从隐式全局改同租户唯一
ALTER TABLE inspection_brands ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE UNIQUE INDEX idx_brands_tenant_code ON inspection_brands (tenant_id, code);
CREATE INDEX idx_brands_tenant ON inspection_brands (tenant_id);

ALTER TABLE inspection_models ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE UNIQUE INDEX idx_models_tenant_code ON inspection_models (tenant_id, code);
CREATE INDEX idx_models_tenant ON inspection_models (tenant_id);

ALTER TABLE inspection_specs ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE UNIQUE INDEX idx_specs_tenant_code ON inspection_specs (tenant_id, code);
CREATE INDEX idx_specs_tenant ON inspection_specs (tenant_id);

ALTER TABLE inspection_grades ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE UNIQUE INDEX idx_grades_tenant_code ON inspection_grades (tenant_id, code);
CREATE INDEX idx_grades_tenant ON inspection_grades (tenant_id);

-- 6. inspection_technical_requirements: 加 tenant_id（引用 M04 码表，跟随隔离）
ALTER TABLE inspection_technical_requirements ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE INDEX idx_tech_req_tenant ON inspection_technical_requirements (tenant_id);

-- 7. audit_events: 加 tenant_id（审计按租户）
ALTER TABLE audit_events ADD COLUMN tenant_id text NOT NULL DEFAULT '';
CREATE INDEX idx_audit_events_tenant ON audit_events (tenant_id);

COMMENT ON COLUMN contracts.tenant_id IS '租户隔离标量（saas 身份平台下发，无 FK）';
COMMENT ON COLUMN sample_receipts.tenant_id IS '租户隔离标量（saas 身份平台下发，无 FK）';
