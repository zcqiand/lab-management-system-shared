using TypeSpec.Http;

// TestRecord — 单个样品单条检测记录（M03.F03 数据录入）。
// parameter/standard 为逻辑 FK 到已废弃 M06，不强制。
namespace Lab.Management.Shared;

// ADR-0056：requirementCode 退役；新增 data —— 动态表单采集原值（Schema/Data
// 解耦，结构定义在 ParamInterface.config）。requirement/result/verdict 保留为
// 汇总快照列（报告/列表直读）。
model TestRecord {
  id: string;
  tenantId: string;
  sampleId: string;

  // 逻辑 FK → inspection_parameters（M06，不强制）
  parameterCode: string;
  // 逻辑 FK → inspection_standards（M06，不强制）
  standardCode?: string;

  @doc("动态表单采集数据（key-value 原值 + 计算产物快照），缺省 {}。")
  data: Record<unknown>;

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
  data?: Record<unknown>;
  requirement: string;
  result: string;
  verdict?: string;
}

model UpdateTestRecordRequest {
  sampleId?: string;
  parameterCode?: string;
  standardCode?: string;
  data?: Record<unknown>;
  requirement?: string;
  result?: string;
  verdict?: string;
}
