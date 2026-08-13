using TypeSpec.Http;

// SampleReceipt — 接样单（M03.F01/F02/F05-F09）。报告字段已并入。
namespace Lab.Management.Shared;

model SampleReceipt {
  id: string;
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
  remark?: string;

  // jsonb：标准码数组 / 检测依据 / 参数缓存
  judgmentBasis?: string[];
  testingBasis?: string[];
  testParameters?: Record<unknown>;

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
  remark?: string;
  judgmentBasis?: string[];
  testingBasis?: string[];
  testParameters?: Record<unknown>;
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
  remark?: string;
  judgmentBasis?: string[];
  testingBasis?: string[];
  testParameters?: Record<unknown>;
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
