using TypeSpec.Http;

// M03.F05 报告审核 / M03.F06 报告批准 / M03.F07 报告发放 / M03.F08 报告归档
// 统一为批量流程动作端点（submit = 推进、return = 退回、withdraw = 撤回）。
// 每个阶段在列表上用 flowStatus 过滤区分。
@route("/receipts/flow")
@tag("report-flow")
namespace Lab.Management.Shared.ReportFlow {
  // M03.F05/F06/F07/F08 批量流程动作
  @post
  op submitFlowAction(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 各阶段列表（审核/批准/发放/归档队列）
  @get
  @route("/queue")
  op listFlowQueue(
    @query stage: FlowStatus,
    @query page?: int32,
    @query pageSize?: int32,
  ): Page<SampleReceipt> | ErrorResponse;
}
