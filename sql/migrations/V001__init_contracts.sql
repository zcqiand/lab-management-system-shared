-- V001__init_contracts.sql
-- 落地 entities: contracts
-- TypeSpec 来源: tsp/models/contract.tsp Contract / ContractStatus
-- ADR-0007：shared/sql/migrations/ 是 DB 持久层 SSOT；后端 ORM 镜像本文件
-- 命名约定：表名复数 snake_case，列名 snake_case；FK 列名 `<entity>_id`
-- 枚举：PG 原生 CREATE TYPE；ORM 用 NAMED_ENUM / MapEnum<> 镜像
-- 注：lab 仓 id 为应用层 uuid 字符串（text），非 PG uuid 生成（与 backup 约定一致）

-- 1. 枚举类型
CREATE TYPE contract_status AS ENUM (
    'active',
    'archived'
);

-- 2. 主表 contracts（M02.F01 合同管理）
CREATE TABLE contracts (
    id                      text        PRIMARY KEY,
    contract_code           text        NOT NULL,
    client_unit             text        NOT NULL,
    project_name            text        NOT NULL,
    project_location        text,
    construction_unit       text        NOT NULL,
    inspection_specialty_code text,     -- 逻辑 FK → inspection_specialties（M06 已废弃，不强制）
    building_unit           text,
    supervisor_unit         text,
    inspection_person       text,
    inspection_phone        text,
    witness_unit            text        NOT NULL,
    witness                 text        NOT NULL,
    witness_phone           text,
    contact_person          text,
    contact_phone           text,
    entrusted_date          text,
    status                  contract_status NOT NULL DEFAULT 'active',
    created_at              text        NOT NULL DEFAULT '',
    updated_at              text        NOT NULL DEFAULT ''
);

CREATE UNIQUE INDEX idx_contracts_code ON contracts (contract_code);

COMMENT ON TABLE contracts IS '合同/委托（M02.F01）。ADR-0007 SQL SSOT。';
COMMENT ON COLUMN contracts.inspection_specialty_code IS '逻辑 FK 到已废弃的 inspection_specialties（M06），不强制约束';
