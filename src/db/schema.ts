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
//  auditEvents                       public.audit_events         (M06)
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
// 约定：
// - 时间列（created_at/updated_at）与 tenant_id 是 TEXT，默认 ''（V001 起的历史设计，
//   区别于 saas 家族的 timestamptz）；业务时间字段（commission_date 等）同为 TEXT。
// - enum 值域：V014 后 12 个业务 enum 全部 TEXT 化，TypeSpec/OpenAPI 层兜底校验；
//   仅 audit_action 保留 PG enum。
// - 索引 / FK / 约束名与 2026-09-13 lab_dev 实测一致（含历史遗留
//   inspection_calculation_rules_pkey），rebaseline 后保持不变。
// - updated_at 由各消费后端应用层维护（saas ADR-0025 D5/D6 同款，lab 无触发器）。

import {
  pgTable,
  pgEnum,
  text,
  integer,
  boolean,
  jsonb,
  timestamp,
  index,
  uniqueIndex,
  primaryKey,
  foreignKey,
} from "drizzle-orm/pg-core";

export const auditAction = pgEnum("audit_action", [
  "login",
  "logout",
  "create",
  "update",
  "delete",
  "flow",
  "export",
  "other",
]);

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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_contracts_tenant").on(t.tenantId),
    uniqueIndex("idx_contracts_tenant_code").on(t.tenantId, t.contractCode),
    foreignKey({
      columns: [t.inspectionSpecialtyCode],
      foreignColumns: [inspectionSpecialties.code],
      name: "contracts_specialty_fk",
    }).onDelete("set null"),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_samples_receipt").on(t.receiptId),
    index("idx_samples_tenant").on(t.tenantId),
    foreignKey({
      columns: [t.receiptId],
      foreignColumns: [sampleReceipts.id],
      name: "samples_receipt_fk",
    }).onDelete("cascade"),
  ],
);

export const testRecords = pgTable(
  "test_records",
  {
    id: text("id").primaryKey(),
    sampleId: text("sample_id").notNull(),
    parameterCode: text("parameter_code").notNull(),
    standardCode: text("standard_code"),
    requirementCode: text("requirement_code"),
    requirement: text("requirement").notNull(),
    result: text("result").notNull(),
    verdict: text("verdict"),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
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

// ── M06 审计 ────────────────────────────────────────────────────────────────

export const auditEvents = pgTable(
  "audit_events",
  {
    id: text("id").primaryKey(),
    action: auditAction("action").notNull(),
    operator: text("operator").notNull(),
    target: text("target").notNull(),
    targetId: text("target_id"),
    detail: text("detail"),
    ip: text("ip"),
    at: text("at").notNull(),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_audit_events_at").on(t.at),
    index("idx_audit_events_operator").on(t.operator),
    index("idx_audit_events_target").on(t.target, t.targetId),
    index("idx_audit_events_tenant").on(t.tenantId),
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
  createdAt: text("created_at").default("").notNull(),
  updatedAt: text("updated_at").default("").notNull(),
});

export const inspectionObjects = pgTable(
  "inspection_objects",
  {
    code: text("code").primaryKey(),
    inspectionSpecialtyCode: text("inspection_specialty_code").notNull(),
    sourceProjectNo: text("source_project_no").notNull(),
    sourceProjectName: text("source_project_name").notNull(),
    name: text("name").notNull(),
    isOptionalForQualification: boolean("is_optional_for_qualification")
      .default(false)
      .notNull(),
    isOfficial: boolean("is_official").default(true).notNull(),
    enabled: boolean("enabled").default(true).notNull(),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
  },
  (t) => [
    index("idx_objects_specialty").on(t.inspectionSpecialtyCode),
    foreignKey({
      columns: [t.inspectionSpecialtyCode],
      foreignColumns: [inspectionSpecialties.code],
      name: "objects_specialty_fk",
    }).onDelete("restrict"),
  ],
);

export const inspectionSpecialtyObjects = pgTable(
  "inspection_specialty_objects",
  {
    inspectionSpecialtyCode: text("inspection_specialty_code").notNull(),
    inspectionObjectCode: text("inspection_object_code").notNull(),
    remark: text("remark"),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
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

// ── M04 检测对象 × 字典（品牌 / 型号 / 规格 / 等级，tenant 隔离）───────────
// 四张字典表结构相同，但索引/FK 名各自独立（与 lab_dev 实测一致），显式逐张声明。

export const inspectionBrands = pgTable(
  "inspection_brands",
  {
    code: text("code").primaryKey(),
    inspectionObjectCode: text("inspection_object_code"),
    name: text("name").notNull(),
    remark: text("remark"),
    sortOrder: integer("sort_order").default(0).notNull(),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_brands_tenant").on(t.tenantId),
    uniqueIndex("idx_brands_tenant_code").on(t.tenantId, t.code),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_models_tenant").on(t.tenantId),
    uniqueIndex("idx_models_tenant_code").on(t.tenantId, t.code),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_specs_tenant").on(t.tenantId),
    uniqueIndex("idx_specs_tenant_code").on(t.tenantId, t.code),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    index("idx_grades_tenant").on(t.tenantId),
    uniqueIndex("idx_grades_tenant_code").on(t.tenantId, t.code),
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
  createdAt: text("created_at").default("").notNull(),
  updatedAt: text("updated_at").default("").notNull(),
});

export const inspectionStandards = pgTable("inspection_standards", {
  code: text("code").primaryKey(),
  name: text("name").notNull(),
  version: text("version"),
  status: text("status").default("active").notNull(),
  sourceDocumentId: text("source_document_id"),
  sourceHash: text("source_hash"),
  sortOrder: integer("sort_order").default(0).notNull(),
  createdAt: text("created_at").default("").notNull(),
  updatedAt: text("updated_at").default("").notNull(),
});

export const inspectionStandardParameters = pgTable(
  "inspection_standard_parameters",
  {
    inspectionStandardCode: text("inspection_standard_code").notNull(),
    inspectionParameterCode: text("inspection_parameter_code").notNull(),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
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
  createdAt: text("created_at").default("").notNull(),
  updatedAt: text("updated_at").default("").notNull(),
});

export const inspectionObjectReportNames = pgTable(
  "inspection_object_report_names",
  {
    inspectionObjectCode: text("inspection_object_code").notNull(),
    reportNameCode: text("report_name_code").notNull(),
    remark: text("remark"),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.reportNameCode, t.inspectionStandardCode, t.role],
      name: "inspection_report_name_standards_pkey",
    }),
    index("idx_rn_std_report").on(t.reportNameCode),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
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
    minValue: integer("min_value"),
    maxValue: integer("max_value"),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
    tenantId: text("tenant_id").default("").notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionParameterCode, t.judgmentStandardCode],
      name: "inspection_technical_requirements_pkey",
    }),
    index("idx_tech_req_object").on(t.inspectionObjectCode),
    index("idx_tech_req_parameter").on(t.inspectionParameterCode),
    index("idx_tech_req_tenant").on(t.tenantId),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionParameterCode],
      // 历史遗留名（V017 重命名表时未同步改约束名），与 lab_dev 实测一致
      name: "inspection_calculation_rules_pkey",
    }),
    index("idx_calc_method_object").on(t.inspectionObjectCode),
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
    componentPath: text("component_path").notNull(),
    description: text("description"),
    isOfficial: boolean("is_official"),
    sortOrder: integer("sort_order").default(0).notNull(),
    config: jsonb("config"),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionParameterCode],
      name: "inspection_object_parameters_pkey",
    }),
    index("idx_obj_params_object").on(t.inspectionObjectCode),
    index("idx_obj_params_param").on(t.inspectionParameterCode),
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
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
  },
  (t) => [
    primaryKey({
      columns: [t.inspectionObjectCode, t.inspectionStandardCode, t.role],
      name: "inspection_object_standards_pkey",
    }),
    index("idx_obj_std_object").on(t.inspectionObjectCode),
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
    config: jsonb("config"),
    createdAt: text("created_at").default("").notNull(),
    updatedAt: text("updated_at").default("").notNull(),
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
  ],
);
