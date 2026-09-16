using TypeSpec.Http;

// M03.F05 报告审核 / M03.F06 报告批准 / M03.F07 报告发放 / M03.F08 报告归档
// 统一为批量流程动作端点（submit = 推进、return = 退回、withdraw = 撤回）。
// 每个阶段在列表上用 flowStatus 过滤区分。
@route("/receipts/flow")
@tag("report-flow")
namespace Lab.Management.Shared.ReportFlow {
  // 批量流程动作（4 F 共享，按 stage query 参数区分阶段，详见 _exempt.tsp §1）
  // 挂载 I：M03.F05.I03 (单条提交/退回 仅前端) / M03.F06.I03 (单条批准/退回 仅前端) /
  //        M03.F07.I03 (单条发放/退回 仅前端) / M03.F08.I03 (单条归档/退回 仅前端) /
  //        M03.F05.I05 (批量提交 仅后端) / M03.F05.I06 (批量退回 仅后端)
  @post
  op submitFlowAction(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 各阶段列表（审核/批准/发放/归档队列，详见 _exempt.tsp §1）
  // 挂载 I：M03.F05.I01 (审核队列) / M03.F06.I01 (批准队列) /
  //        M03.F07.I01 (发放队列) / M03.F08.I01 (归档队列)
  @get
  @route("/queue")
  op listFlowQueue(
    @query stage: FlowStatus,
    @query page?: int32,
    @query pageSize?: int32,
  ): Page<SampleReceipt> | ErrorResponse;
}