using TypeSpec.Http;

// Common enums shared across M03 flow pipeline.
namespace Lab.Management.Shared;

// M03 试验流程 8 阶段（与 backup FlowStageEnum 一致）
enum FlowStatus {
  receiving,
  task_assignment,
  data_entry,
  review,
  approval,
  issuance,
  archived,
  completed,
}

// M03 流程动作（submit / return / withdraw）
enum FlowAction {
  submit,
  "return",
  withdraw,
}

// 接样单检测结果（空串 = 未评定）
enum ReceiptResult {
  @doc("通过")
  "pass",
  @doc("不通过")
  "fail",
  @doc("未评定")
  "",
}

// 流程历史条目（flow_history jsonb 数组元素）
model FlowHistoryEntry {
  action: FlowAction;
  from: FlowStatus;
  to: FlowStatus;
  operator: string;
  at: string;
  reason?: string;
}

// 流程动作结果
model FlowActionResult {
  id: string;
  ok: boolean;
  message?: string;
  flowStatus?: FlowStatus;
}
