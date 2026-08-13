using TypeSpec.Http;

// TestRecord — 单个样品单条检测记录（M03.F03 数据录入）。
// parameter/standard 为逻辑 FK 到已废弃 M06，不强制。
namespace Lab.Management.Shared;

model TestRecord {
  id: string;
  sampleId: string;

  // 逻辑 FK → inspection_parameters（M06，不强制）
  parameterCode: string;
  // 逻辑 FK → inspection_standards（M06，不强制）
  standardCode?: string;
  // 逻辑 FK → inspection_technical_requirements（M04.F05）
  requirementCode?: string;

  requirement: string;
  result: string;
  verdict?: string;

  createdAt: string;
  updatedAt: string;
}

model CreateTestRecordRequest {
  sampleId: string;
  parameterCode: string;
  standardCode?: string;
  requirementCode?: string;
  requirement: string;
  result: string;
  verdict?: string;
}

model UpdateTestRecordRequest {
  sampleId?: string;
  parameterCode?: string;
  standardCode?: string;
  requirementCode?: string;
  requirement?: string;
  result?: string;
  verdict?: string;
}
