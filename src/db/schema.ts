// src/db/schema.ts — lab-management-system DB SSOT（ADR-0025 schema-first / ADR-0033 阶段一）
//
// 手写 Drizzle schema 是 DB 持久层唯一真相源；`npm run db:generate` 物化成
// drizzle/0000_*.sql baseline 入 git；消费仓（springboot/aspnetcore/nextjs/msw）
// 从真库反向工程，本文件不再直接给任何仓拷贝。
//
// =====================================================================
// TS model ↔ DB table mapping（自 sql/migrations V001-V017 终态收敛，
// 2026-09-13 introspect lab_dev @ 100.79.128.25。旧手写 SQL 目录 sql/ 已删除，
// DDL 历史看 git log -- sql/）
// =====================================================================
//
//  pgTable export                    DB table
//  ─────────────────────────────────────────────────────────────────
//  contracts                         public.contracts            (M02)
//  sampleReceipts                    public.sample_receipts      (M03)
//  samples                           public.samples              (M03)
//  testRecords                       public.test_records         (M03)
//  inspectionSpecialties             public.inspection_specialties         (M04)
//  inspectionObjects                 public.inspection_objects             (M04)
//  inspectionSpecialtyObjects        public.inspection_specialty_objects   (M04)
//  inspectionParameters              public.inspection_parameters          (M04)
//  inspectionStandards               public.inspection_standards           (M04)
//  inspectionStandardParameters      public.inspection_standard_parameters (M04)
//  inspectionObjectParameters        public.inspection_object_parameters   (M04)
//  inspectionObjectStandards         public.inspection_object_standards    (M04)
//  inspectionReportNames             public.inspection_report_names        (M05)
//  inspectionObjectReportNames       public.inspection_object_report_names (M05)
//  inspectionReportNameStandards     public.inspection_report_name_standards (M05)
//  inspectionReportNameParameters    public.inspection_report_name_parameters (M05)
//  inspectionBrands                  public.inspection_brands     (M04 字典)
//  inspectionModels                  public.inspection_models     (M04 字典)
//  inspectionSpecs                   public.inspection_specs      (M04 字典)
//  inspectionGrades                  public.inspection_grades     (M04 字典)
//  inspectionCalculationMethods      public.inspection_calculation_methods (M06, V017 由 rules 重命名)
//  inspectionParamInterfaces         public.inspection_param_interfaces     (M10)
//  inspectionParamInterfaceLinks     public.inspection_param_interface_links (M10)
//
// 约定（2026-11-09 六裁定修订，2026-11-09 人批）：
// - 时间列 created_at/updated_at 全库 timestamptz notNull default now()
//   （原 TEXT default '' 历史设计退役；应用层维护 updated_at 语义保留，DB 兜底 now()；
//    消费端 ISO UTC 字符串写入经 mode:"string" 直通）。业务时间字段
//   （commission_date 等）仍 TEXT（表单数据，非元数据）。
// - 租户语义：业务表（contracts/sample_receipts/samples/test_records）tenant_id
//   隔离；目录/字典类（inspection_* 全部 catalog 表含四小字典与技术要求）全局
//   共享、无 tenant_id（2026-11-09 人裁：原 brands/models/specs/grades 的
//   tenant 唯一索引自相矛盾、tech_req PK 缺 tenant 跨租户必撞，一并归全局）。
// - enum 值域：业务 enum 列全部 TEXT + DB CHECK 约束兜底（ck_* 命名，值域与
//   TypeSpec enum 一字不差，含 RequirementComparison 的 ≥/≤/= 符号；值域变更
//   = shared 改 tsp enum + schema check 同 commit）；audit_action PG enum 已随
//   audit_events 表清理删除（2026-09-20，5.65）。
// - 索引 / FK / 约束名与 2026-09-13 lab_dev 实测一致（含历史遗留
//   inspection_calculation_rules_pkey），rebaseline 后保持不变；
//   2026-11-09 六裁定批 drizzle/ 全量重新 baseline（老 ALTER 对 TEXT 时间列
//   无法 USING 迁移，走 drop+重灌种子，先例 backups/lab_dev-backup-20260913.json）。
// - updated_at 由各消费后端应用层维护（saas ADR-0025 D5/D6 同款，lab 无触发器）。
// - inspection_objects 与专项关系以 junction 表 inspection_specialty_objects
//   为唯一真源（M:N）；objects 直挂列已删（2026-11-09 人裁 #5，删前实测
//   111 对直挂与 junction 完全一致，零数据丢失）。

import {
  pgTable,
  text,
  integer,
  numeric,
  boolean,
  jsonb,
  timestamp,
  index,
  uniqueIndex,
  primaryKey,
  foreignKey,
  check,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

// ── M02 合同 ────────────────────────────────────────────────────────────────

export const contracts = pgTable(
  "contracts",
  {
    id: text("id").primaryKey(),
    contractCode: text("contract_code").notNull(),
    clientUnit: text("client_unit").notNull(),
    projectName: text("project_name").notNull(),
    projectLocation: text("project_location"),
    constructionUnit: text("construction_unit").notNull(),
    inspectionSpecialtyCode: text("inspection_specialty_code"),
    buildingUnit: text("building_unit"),
    supervisorUnit: text("supervisor_unit"),
    inspectionPerson: text("inspection_person"),
    inspectionPhone: text("inspection_phone"),
    witnessUnit: text("witness_unit").notNull(),
    witness: text("witness").notNull(),
    witnessPhone: text("witness_phone"),
    contactPerson: text("contact_person"),
    contactPhone: text("contact_phone"),
    entrustedDate: text("entrusted_date"),
    status: text("status").default("active").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    tenantId: text("tenant_id").notNull(),
  },
  (t) => [
    index("idx_contracts_tenant").on(t.tenantId),
    uniqueIndex("idx_contracts_tenant_code").on(t.tenantId, t.contractCode),
    foreignKey({
      columns: [t.inspectionSpecialtyCode],
      foreignColumns: [inspectionSpecialties.code],
      name: "contracts_specialty_fk",
    }).onDelete("set null"),
    check("ck_contracts_status", sql`${t.status} in ('active', 'archived')`),
  ],
);

// ── M03 样品受理 / 样品 / 检测记录 ─────────────────────────────────────────

export const sampleReceipts = pgTable(
  "sample_receipts",
  {
    id: text("id").primaryKey(),
    contractId: text("contract_id").notNull(),
    commissionCode: text("commission_code").notNull(),
    commissionDate: text("commission_date").notNull(),
    commissionRegisterCode: text("commission_register_code"),
    commissionRegisterDate: text("commission_register_date"),
    categoryCode: text("category_code").notNull(),
    // 快照语义（2026-11-09 中危 #10）：projectName 至 witnessPhone 为接样时刻自
    // 合同/委托单冻结的副本，不随合同后续变更联动；取值链 = 合同带出 → 接样单可覆盖。
    projectName: text("project_name"),
    clientUnit: text("client_unit"),
    buildingUnit: text("building_unit"),
    supervisorUnit: text("supervisor_unit"),
    constructionUnit: text("construction_unit"),
    witnessUnit: text("witness_unit"),
    samplingLocation: text("sampling_location"),
    witness: text("witness"),
    witnessPhone: text("witness_phone"),
    inspector: text("inspector"),
    inspectorPhone: text("inspector_phone"),
    receivedBy: text("received_by").notNull(),
    sampleSource: text("sample_source").notNull(),
    testCategory: text("test_category").notNull(),
    testEnvironment: text("test_environment"),
    mainEquipment: text("main_equipment"),
    testOperator: text("test_operator"),
    testStartDate: text("test_start_date"),
    testEndDate: text("test_end_date"),
    originalRecordNo: text("original_record_no"),
    remark: text("remark"),
    judgmentBasis: jsonb("judgment_basis"),
    testingBasis: jsonb("testing_basis"),
    testParameters: jsonb("test_parameters"),
    ext: jsonb("ext").default({}).notNull(),
    flowStatus: text("flow_status").default("receiving").notNull(),
    flowHistory: jsonb("flow_history").default([]).notNull(),
    lastSubmittedBy: text("last_submitted_by"),
    assigneeId: text("assignee_id"),
    assigneeName: text("assignee_name"),
    plannedTestDate: text("planned_test_date"),
    reportCode: text("report_code"),
    reportDate: text("report_date"),
    conclusion: text("conclusion"),
    result: text("result"),
    issuedAt: timestamp("issued_at", { withTimezone: true, mode: "string" }),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    tenantId: text("tenant_id").notNull(),
  },
  (t) => [
    index("idx_receipts_tenant").on(t.tenantId),
    uniqueIndex("idx_receipts_tenant_commission").on(t.tenantId, t.commissionCode),
    index("idx_sample_receipts_category").on(t.categoryCode),
    index("idx_sample_receipts_contract").on(t.contractId),
    index("idx_sample_receipts_flow_status").on(t.flowStatus),
    foreignKey({
      columns: [t.contractId],
      foreignColumns: [contracts.id],
      name: "sample_receipts_contract_fk",
    }).onDelete("restrict"),
    foreignKey({
      columns: [t.categoryCode],
      foreignColumns: [inspectionReportNames.code],
      name: "receipts_category_fk",
    }).onDelete("restrict"),
    check(
      "ck_receipts_flow_status",
      sql`${t.flowStatus} in ('receiving', 'task_assignment', 'data_entry', 'review', 'approval', 'issuance', 'archived', 'completed')`,
    ),
  ],
);

export const samples = pgTable(
  "samples",
  {
    id: text("id").primaryKey(),
    receiptId: text("receipt_id").notNull(),
    sampleCode: text("sample_code").notNull(),
    sampleName: text("sample_name"),
    model: text("model"),
    specification: text("specification"),
    grade: text("grade"),
    brand: text("brand"),
    manufacturer: text("manufacturer"),
    structuralPart: text("structural_part"),
    representQuantity: text("represent_quantity"),
    sampleQuantity: text("sample_quantity"),
    batchNumber: text("batch_number"),
    supplyUnit: text("supply_unit"),
    arrivalDate: text("arrival_date"),
    samplingDate: text("sampling_date"),
    curingCondition: text("curing_condition"),
    age: text("age"),
    ext: jsonb("ext").default({}).notNull(),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    tenantId: text("tenant_id").notNull(),
  },
  (t) => [
    index("idx_samples_receipt").on(t.receiptId),
    uniqueIndex("idx_samples_tenant_code").on(t.tenantId, t.sampleCode),
    foreignKey({
      columns: [t.receiptId],
      foreignColumns: [sampleReceipts.id],
      name: "samples_receipt_fk",
    }).onDelete("cascade"),
    // model/specification/grade/brand 保持裸 TEXT（2026-11-09 人裁翻案：不做字典 FK）。
    // 字典表（brands/models/specs/grades）的职责 = 值域校验 + UI 选项来源——引用字段的
    // 值「不是自由输入而是从字典选择」，应用层负责校验；DB 层保留自由 TEXT，
    // 历史数据（如 specification='标准试样' 等字典外值）不受 FK 阻塞。
  ],
);

export const testRecords = pgTable(
  "test_records",
  {
    id: text("id").primaryKey(),
    sampleId: text("sample_id").notNull(),
    parameterCode: text("parameter_code").notNull(),
    standardCode: text("standard_code"),
    /**
     * 动态表单数据（Data）——按所属参数界面 config.schema 采集的 key-value
     * 原值 + 计算产物快照（ADR-0056 Schema/Data 解耦）。requirement/result/
     * verdict 保留为汇总快照列（报告/列表直读，不必解 JSON）。
     */
    data: jsonb("data").default({}).notNull(),
    requirement: text("requirement").notNull(),
    result: text("result").notNull(),
    verdict: text("verdict"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    tenantId: text("tenant_id").notNull(),
  },
  (t) => [
    index("idx_test_records_sample").on(t.sampleId),
    index("idx_test_records_tenant").on(t.tenantId),
    foreignKey({
      columns: [t.sampleId],
      foreignColumns: [samples.id],
      name: "test_records_sample_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.parameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "testrec_param_fk",
    }).onDelete("restrict"),
    foreignKey({
      columns: [t.standardCode],
      foreignColumns: [inspectionStandards.code],
      name: "testrec_standard_fk",
    }).onDelete("set null"),
  ],
);

// ── M04 检测目录：专业 / 检测对象 ───────────────────────────────────────────

export const inspectionSpecialties = pgTable("inspection_specialties", {
  code: text("code").primaryKey(),
  officialNo: text("official_no").notNull(),
  name: text("name").notNull(),
  isOfficial: boolean("is_official").default(true).notNull(),
  enabled: boolean("enabled").default(true).notNull(),
  sortOrder: integer("sort_order").default(0).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
});

export const inspectionObjects = pgTable(
  "inspection_objects",
  {
    code: text("code").primaryKey(),
    sourceProjectNo: text("source_project_no").notNull(),
    sourceProjectName: text("source_project_name").notNull(),
    name: text("name").notNull(),
    isOptionalForQualification: boolean("is_optional_for_qualification")
      .default(false)
      .notNull(),
    isOfficial: boolean("is_official").default(true).notNull(),
    enabled: boolean("enabled").default(true).notNull(),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
});

export const inspectionSpecialtyObjects = pgTable(
  "inspection_specialty_objects",
  {
    inspectionSpecialtyCode: text("inspection_specialty_code").notNull(),
    inspectionObjectCode: text("inspection_object_code").notNull(),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionSpecialtyCode, t.inspectionObjectCode],
      name: "inspection_specialty_objects_pkey",
    }),
    foreignKey({
      columns: [t.inspectionSpecialtyCode],
      foreignColumns: [inspectionSpecialties.code],
      name: "specialty_objects_specialty_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "specialty_objects_object_fk",
    }).onDelete("cascade"),
  ],
);

// ── M04 检测对象 × 字典（品牌 / 型号 / 规格 / 等级，全局共享）───────────────
// 四张字典表结构相同，索引/FK 名各自独立（与 lab_dev 实测一致），显式逐张声明。
// 2026-11-09 人裁：字典表全局共享、无 tenant_id（PK=code 唯一真源）。

export const inspectionBrands = pgTable(
  "inspection_brands",
  {
    code: text("code").primaryKey(),
    inspectionObjectCode: text("inspection_object_code"),
    name: text("name").notNull(),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    index("idx_inspection_brands_object").on(t.inspectionObjectCode),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "brands_object_fk",
    }).onDelete("set null"),
  ],
);

export const inspectionModels = pgTable(
  "inspection_models",
  {
    code: text("code").primaryKey(),
    inspectionObjectCode: text("inspection_object_code"),
    name: text("name").notNull(),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    index("idx_inspection_models_object").on(t.inspectionObjectCode),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "models_object_fk",
    }).onDelete("set null"),
  ],
);

export const inspectionSpecs = pgTable(
  "inspection_specs",
  {
    code: text("code").primaryKey(),
    inspectionObjectCode: text("inspection_object_code"),
    name: text("name").notNull(),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    index("idx_inspection_specs_object").on(t.inspectionObjectCode),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "specs_object_fk",
    }).onDelete("set null"),
  ],
);

export const inspectionGrades = pgTable(
  "inspection_grades",
  {
    code: text("code").primaryKey(),
    inspectionObjectCode: text("inspection_object_code"),
    name: text("name").notNull(),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    index("idx_inspection_grades_object").on(t.inspectionObjectCode),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "grades_object_fk",
    }).onDelete("set null"),
  ],
);

// ── M04 参数 / 标准 ─────────────────────────────────────────────────────────

export const inspectionParameters = pgTable("inspection_parameters", {
  code: text("code").primaryKey(),
  name: text("name").notNull(),
  rawName: text("raw_name").notNull(),
  canonicalName: text("canonical_name").notNull(),
  methodText: text("method_text"),
  aliases: jsonb("aliases").default([]).notNull(),
  unit: text("unit"),
  sourceType: text("source_type").default("official").notNull(),
  sortOrder: integer("sort_order").default(0).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
}, (t) => [
  check("ck_params_source_type", sql`${t.sourceType} in ('official', 'custom')`),
]);

export const inspectionStandards = pgTable("inspection_standards", {
  code: text("code").primaryKey(),
  name: text("name").notNull(),
  version: text("version"),
  status: text("status").default("active").notNull(),
  sourceDocumentId: text("source_document_id"),
  sourceHash: text("source_hash"),
  sortOrder: integer("sort_order").default(0).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
}, (t) => [
  check("ck_standards_status", sql`${t.status} in ('active', 'superseded', 'draft')`),
]);

export const inspectionStandardParameters = pgTable(
  "inspection_standard_parameters",
  {
    inspectionStandardCode: text("inspection_standard_code").notNull(),
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionStandardCode, t.inspectionParameterCode],
      name: "inspection_standard_parameters_pkey",
    }),
    index("idx_std_param_standard").on(t.inspectionStandardCode),
    foreignKey({
      columns: [t.inspectionStandardCode],
      foreignColumns: [inspectionStandards.code],
      name: "std_param_standard_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionParameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "std_param_parameter_fk",
    }).onDelete("cascade"),
  ],
);

// ── M05 报告名 ──────────────────────────────────────────────────────────────

export const inspectionReportNames = pgTable("inspection_report_names", {
  code: text("code").primaryKey(),
  name: text("name").notNull(),
  fullName: text("full_name"),
  templatePath: text("template_path"),
  summaryName: text("summary_name"),
  extFields: jsonb("ext_fields"),
  description: text("description"),
  sortOrder: integer("sort_order").default(0).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
});

export const inspectionObjectReportNames = pgTable(
  "inspection_object_report_names",
  {
    inspectionObjectCode: text("inspection_object_code").notNull(),
    reportNameCode: text("report_name_code").notNull(),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.reportNameCode],
      name: "inspection_object_report_names_pkey",
    }),
    index("idx_obj_rn_object").on(t.inspectionObjectCode),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "obj_rn_object_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.reportNameCode],
      foreignColumns: [inspectionReportNames.code],
      name: "obj_rn_report_fk",
    }).onDelete("cascade"),
  ],
);

export const inspectionReportNameStandards = pgTable(
  "inspection_report_name_standards",
  {
    reportNameCode: text("report_name_code").notNull(),
    inspectionStandardCode: text("inspection_standard_code").notNull(),
    role: text("role").notNull(),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.reportNameCode, t.inspectionStandardCode, t.role],
      name: "inspection_report_name_standards_pkey",
    }),
    index("idx_rn_std_report").on(t.reportNameCode),
    check("ck_rn_std_role", sql`${t.role} in ('TESTING', 'JUDGMENT')`),
    foreignKey({
      columns: [t.reportNameCode],
      foreignColumns: [inspectionReportNames.code],
      name: "rn_std_report_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionStandardCode],
      foreignColumns: [inspectionStandards.code],
      name: "rn_std_standard_fk",
    }).onDelete("cascade"),
  ],
);

export const inspectionReportNameParameters = pgTable(
  "inspection_report_name_parameters",
  {
    reportNameCode: text("report_name_code").notNull(),
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.reportNameCode, t.inspectionParameterCode],
      name: "inspection_report_name_parameters_pkey",
    }),
    index("idx_rn_param_report").on(t.reportNameCode),
    foreignKey({
      columns: [t.reportNameCode],
      foreignColumns: [inspectionReportNames.code],
      name: "rn_param_report_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionParameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "rn_param_parameter_fk",
    }).onDelete("cascade"),
  ],
);

// ── M04.F05 技术要求 ────────────────────────────────────────────────────────

export const inspectionTechnicalRequirements = pgTable(
  "inspection_technical_requirements",
  {
    inspectionObjectCode: text("inspection_object_code").notNull(),
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    judgmentStandardCode: text("judgment_standard_code").notNull(),
    conditions: text("conditions"),
    valueType: text("value_type").default("numeric").notNull(),
    minValue: numeric("min_value", { precision: 12, scale: 4 }),
    maxValue: numeric("max_value", { precision: 12, scale: 4 }),
    targetValue: text("target_value"),
    expression: text("expression"),
    unit: text("unit"),
    comparison: text("comparison").notNull(),
    judgmentMode: text("judgment_mode").default("manual").notNull(),
    verificationStatus: text("verification_status").default("draft").notNull(),
    clause: text("clause"),
    sourcePage: integer("source_page"),
    sourceHash: text("source_hash"),
    brand: text("brand"),
    model: text("model"),
    grade: text("grade"),
    spec: text("spec"),
    sieve: text("sieve"),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionParameterCode, t.judgmentStandardCode],
      name: "inspection_technical_requirements_pkey",
    }),
    index("idx_tech_req_object").on(t.inspectionObjectCode),
    index("idx_tech_req_parameter").on(t.inspectionParameterCode),
    check(
      "ck_tech_req_value_type",
      sql`${t.valueType} in ('numeric', 'string', 'range', 'formula', 'manual')`,
    ),
    check(
      "ck_tech_req_comparison",
      sql`${t.comparison} in ('≥', '≤', '=', 'range', 'eq')`,
    ),
    check(
      "ck_tech_req_judgment_mode",
      sql`${t.judgmentMode} in ('automatic', 'manual')`,
    ),
    check(
      "ck_tech_req_verification_status",
      sql`${t.verificationStatus} in ('draft', 'reviewed', 'verified', 'rejected')`,
    ),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "tech_req_object_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionParameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "tech_req_parameter_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.judgmentStandardCode],
      foreignColumns: [inspectionStandards.code],
      name: "tech_req_judgment_standard_fk",
    }).onDelete("restrict"),
    foreignKey({
      columns: [t.brand],
      foreignColumns: [inspectionBrands.code],
      name: "tech_req_brand_fk",
    }).onDelete("set null"),
    foreignKey({
      columns: [t.model],
      foreignColumns: [inspectionModels.code],
      name: "tech_req_model_fk",
    }).onDelete("set null"),
    foreignKey({
      columns: [t.grade],
      foreignColumns: [inspectionGrades.code],
      name: "tech_req_grade_fk",
    }).onDelete("set null"),
    foreignKey({
      columns: [t.spec],
      foreignColumns: [inspectionSpecs.code],
      name: "tech_req_spec_fk",
    }).onDelete("set null"),
  ],
);

// ── M06 计算方法（V017 由 inspection_calculation_rules 重命名）──────────────

export const inspectionCalculationMethods = pgTable(
  "inspection_calculation_methods",
  {
    inspectionObjectCode: text("inspection_object_code").notNull(),
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    testingStandardCode: text("testing_standard_code"),
    reportNameCode: text("report_name_code"),
    algorithmType: text("algorithm_type").default("manual").notNull(),
    specimenCount: integer("specimen_count").default(1).notNull(),
    formula: text("formula"),
    conditions: text("conditions"),
    roundingRule: text("rounding_rule"),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionParameterCode],
      // 历史遗留名（V017 重命名表时未同步改约束名），与 lab_dev 实测一致
      name: "inspection_calculation_rules_pkey",
    }),
    index("idx_calc_method_object").on(t.inspectionObjectCode),
    check(
      "ck_calc_algorithm_type",
      sql`${t.algorithmType} in ('simple_avg', 'compressive_strength', 'flexural_strength', 'steel_tensile', 'formula', 'manual', 'auto_calc_ratio')`,
    ),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "calc_rule_object_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionParameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "calc_rule_parameter_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.testingStandardCode],
      foreignColumns: [inspectionStandards.code],
      name: "calc_rule_standard_fk",
    }).onDelete("set null"),
    foreignKey({
      columns: [t.reportNameCode],
      foreignColumns: [inspectionReportNames.code],
      name: "calc_rule_report_fk",
    }).onDelete("set null"),
  ],
);

// ── M10 参数接口 ────────────────────────────────────────────────────────────

export const inspectionParamInterfaces = pgTable(
  "inspection_param_interfaces",
  {
    code: text("code").notNull(),
    name: text("name"),
    description: text("description"),
    /** 结构版本（表单结构迭代升级用；渲染器按 schema 演进向前兼容）。 */
    version: integer("version").default(1).notNull(),
    /**
     * 表单结构定义（Schema）——JSON 动态表单的渲染真源（ADR-0056）。
     * 形状：{ title?, fields: FieldSpec[], computed?: ComputedSpec[], params? }
     * fields=采集面（input/textarea/number/select/number_series/table，
     * 含 label/required/rules/options/defaultValue）；computed=计算面，
     * 引用算法域（inspection_calculation_methods.algorithm_type 同域）；
     * params=算法域入参（area/span 等常数，随表单走）。
     * 数据面在 test_records.data（key-value 采集原值），两相解耦。
     */
    config: jsonb("config"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    // 主键约束名保留 V013 改表名前的遗留名 param_interfaces_pkey（lab_dev 实测）
    primaryKey({ columns: [t.code], name: "param_interfaces_pkey" }),
  ],
);

export const inspectionObjectParameters = pgTable(
  "inspection_object_parameters",
  {
    inspectionObjectCode: text("inspection_object_code").notNull(),
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    qualificationLevel: text("qualification_level").default("QUALIFIED").notNull(),
    sourcePage: integer("source_page"),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionParameterCode],
      name: "inspection_object_parameters_pkey",
    }),
    index("idx_obj_params_object").on(t.inspectionObjectCode),
    index("idx_obj_params_param").on(t.inspectionParameterCode),
    check("ck_obj_params_qual_level", sql`${t.qualificationLevel} in ('QUALIFIED', 'RESTRICTED')`),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "obj_params_object_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionParameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "obj_params_parameter_fk",
    }).onDelete("cascade"),
  ],
);

export const inspectionObjectStandards = pgTable(
  "inspection_object_standards",
  {
    inspectionObjectCode: text("inspection_object_code").notNull(),
    inspectionStandardCode: text("inspection_standard_code").notNull(),
    role: text("role").notNull(),
    remark: text("remark"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionStandardCode, t.role],
      name: "inspection_object_standards_pkey",
    }),
    index("idx_obj_std_object").on(t.inspectionObjectCode),
    check("ck_obj_std_role", sql`${t.role} in ('TESTING', 'JUDGMENT')`),
    foreignKey({
      columns: [t.inspectionObjectCode],
      foreignColumns: [inspectionObjects.code],
      name: "obj_std_object_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.inspectionStandardCode],
      foreignColumns: [inspectionStandards.code],
      name: "obj_std_standard_fk",
    }).onDelete("cascade"),
  ],
);

export const inspectionParamInterfaceLinks = pgTable(
  "inspection_param_interface_links",
  {
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    paramInterfaceCode: text("param_interface_code").notNull(),
    reportNameCode: text("report_name_code"),
    /** 绑定检测依据（可空=不限依据）；与 report_name_code 同款作用域语义（ADR-0056）。 */
    inspectionStandardCode: text("inspection_standard_code"),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "string" }).defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionParameterCode, t.paramInterfaceCode],
      name: "param_interface_links_pkey",
    }),
    index("idx_pil_param").on(t.inspectionParameterCode),
    foreignKey({
      columns: [t.inspectionParameterCode],
      foreignColumns: [inspectionParameters.code],
      name: "pil_param_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.paramInterfaceCode],
      foreignColumns: [inspectionParamInterfaces.code],
      name: "pil_interface_fk",
    }).onDelete("cascade"),
    foreignKey({
      columns: [t.reportNameCode],
      foreignColumns: [inspectionReportNames.code],
      name: "pil_report_fk",
    }).onDelete("set null"),
    foreignKey({
      columns: [t.inspectionStandardCode],
      foreignColumns: [inspectionStandards.code],
      name: "pil_standard_fk",
    }).onDelete("set null"),
  ],
);
