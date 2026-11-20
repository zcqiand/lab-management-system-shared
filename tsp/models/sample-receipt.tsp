using TypeSpec.Http;

// SampleReceipt — 接样单（M03.F01/F02/F05-F09）。报告字段已并入。
namespace Lab.Management.Shared;

// M03 复验方式（2026-11-10 人裁）：double = 双倍取样复验；original = 原样数量复验
enum RetestMode {
  none,
  double,
  original,
}

model SampleReceipt {
  id: string;
  tenantId: string;
  contractId: string;

  commissionCode: string;
  commissionDate: string;
  commissionRegisterCode?: string;
  commissionRegisterDate?: string;

  // 逻辑 FK → inspection_report_names（M06，不强制）
  categoryCode: string;

  projectName?: string;
  clientUnit?: string;
  buildingUnit?: string;
  supervisorUnit?: string;
  constructionUnit?: string;
  witnessUnit?: string;
  samplingLocation?: string;
  witness?: string;
  witnessPhone?: string;
  inspector?: string;
  inspectorPhone?: string;

  receivedBy: string;
  sampleSource: string;
  testCategory: string;

  testEnvironment?: string;
  mainEquipment?: string;
  testOperator?: string;
  testStartDate?: string;
  testEndDate?: string;
  originalRecordNo?: string;
  // 复验方式：double = 双倍取样复验（数据录入侧界面 config 翻倍 rows/count ×2，
  // 2026-11-20 收敛批）；original = 原样数量复验（常规行数，仅标记供报告特殊处理）
  retestMode?: RetestMode;
  remark?: string;

  // jsonb：标准码数组 / 检测依据 / 参数码数组（FK → InspectionParameter.code）
  judgmentBasis?: string[];
  testingBasis?: string[];
  testParameters?: string[];

  flowStatus: FlowStatus;
  flowHistory: FlowHistoryEntry[];

  lastSubmittedBy?: string;

  // M03.F02 任务分配
  assigneeId?: string;
  assigneeName?: string;
  plannedTestDate?: string;

  // 报告字段（并入接样单）
  reportCode?: string;
  reportDate?: string;
  conclusion?: string;
  result?: ReceiptResult;
  issuedAt?: string;

  createdAt: string;
  updatedAt: string;
}

model CreateSampleReceiptRequest {
  contractId: string;
  commissionCode: string;
  commissionDate: string;
  commissionRegisterCode?: string;
  commissionRegisterDate?: string;
  categoryCode: string;
  projectName?: string;
  clientUnit?: string;
  buildingUnit?: string;
  supervisorUnit?: string;
  constructionUnit?: string;
  witnessUnit?: string;
  samplingLocation?: string;
  witness?: string;
  witnessPhone?: string;
  inspector?: string;
  inspectorPhone?: string;
  receivedBy: string;
  sampleSource: string;
  testCategory: string;
  testEnvironment?: string;
  mainEquipment?: string;
  testOperator?: string;
  testStartDate?: string;
  testEndDate?: string;
  originalRecordNo?: string;
  retestMode?: RetestMode;
  remark?: string;
  judgmentBasis?: string[];
  testingBasis?: string[];
  testParameters?: string[];
}

model UpdateSampleReceiptRequest {
  contractId?: string;
  commissionCode?: string;
  commissionDate?: string;
  commissionRegisterCode?: string;
  commissionRegisterDate?: string;
  categoryCode?: string;
  projectName?: string;
  clientUnit?: string;
  buildingUnit?: string;
  supervisorUnit?: string;
  constructionUnit?: string;
  witnessUnit?: string;
  samplingLocation?: string;
  witness?: string;
  witnessPhone?: string;
  inspector?: string;
  inspectorPhone?: string;
  receivedBy?: string;
  sampleSource?: string;
  testCategory?: string;
  testEnvironment?: string;
  mainEquipment?: string;
  testOperator?: string;
  testStartDate?: string;
  testEndDate?: string;
  originalRecordNo?: string;
  retestMode?: RetestMode;
  remark?: string;
  judgmentBasis?: string[];
  testingBasis?: string[];
  testParameters?: string[];
}

// M03.F02 任务分配请求
model AssignTaskRequest {
  assigneeId?: string;
  assigneeName?: string;
  plannedTestDate?: string;
}

// M03.F05-F08 流程批量动作请求
model FlowActionRequest {
  ids: string[];
  action: FlowAction;
  operator: string;
  reason?: string;
}
