using TypeSpec.Http;

// M03.F01 接样-流程 / M03.F02 任务分配-流程 / M03.F03 数据录入-流程 /
// M03.F05 报告审核 / M03.F06 报告批准 / M03.F07 报告发放 / M03.F08 报告归档
// 2026-09-17 §1 拆端点：原 7 F 共享 POST /receipts/flow + 4 F 共享 GET /receipts/flow/queue
// 按 stage + action 拆为 15 + 4 个独立端点（不豁免替代 = 1:1 命中）。
// submit = 推进、return = 退回、withdraw = 撤回（仅 F01/F02/F03）。
// 报告 4 阶段 I03 的「通过/退回」合并到 act 端点（body.action 区分 submit/return）。
@route("/receipts")
@tag("report-flow")
namespace Lab.Management.Shared.ReportFlow {
  // 接样阶段流程动作（按 action 拆 3 端点）
  // 挂载 I：M03.F01.I08
  @route("/receiving/submit")
  @post
  op submitFlowReceivingSubmit(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F01.I09
  @route("/receiving/return")
  @post
  op returnFlowReceiving(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F01.I10
  @route("/receiving/withdraw")
  @post
  op withdrawFlowReceiving(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 任务分配阶段流程动作（按 action 拆 3 端点）
  // 挂载 I：M03.F02.I05
  @route("/assigning/submit")
  @post
  op submitFlowAssigningSubmit(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F02.I06
  @route("/assigning/return")
  @post
  op returnFlowAssigning(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F02.I07
  @route("/assigning/withdraw")
  @post
  op withdrawFlowAssigning(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 数据录入阶段流程动作（按 action 拆 3 端点）
  // 挂载 I：M03.F03.I12
  @route("/data-entry/submit")
  @post
  op submitFlowDataEntrySubmit(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F03.I13
  @route("/data-entry/return")
  @post
  op returnFlowDataEntry(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F03.I14
  @route("/data-entry/withdraw")
  @post
  op withdrawFlowDataEntry(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告审核阶段流程动作
  // 挂载 I：M03.F05.I03（act = submit/return 共用端点，body.action 区分）
  @route("/review/act")
  @post
  op actFlowReview(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F05.I05（批量提交）
  @route("/review/batch-submit")
  @post
  op batchSubmitFlowReview(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 挂载 I：M03.F05.I06（批量退回）
  @route("/review/batch-return")
  @post
  op batchReturnFlowReview(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告批准阶段流程动作
  // 挂载 I：M03.F06.I03（act = submit/return 共用端点）
  @route("/approve/act")
  @post
  op actFlowApprove(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告发放阶段流程动作
  // 挂载 I：M03.F07.I03（act = submit/return 共用端点）
  @route("/issuance/act")
  @post
  op actFlowIssuance(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告归档阶段流程动作
  // 挂载 I：M03.F08.I03（act = submit/return 共用端点）
  @route("/archived/act")
  @post
  op actFlowArchived(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 各阶段队列（4 端点）
  // 挂载 I：M03.F05.I01
  @route("/review/queue")
  @get
  op listReviewQueue(
    @query page?: int32,
    @query pageSize?: int32,
  ): Page<SampleReceipt> | ErrorResponse;

  // 挂载 I：M03.F06.I01
  @route("/approve/queue")
  @get
  op listApproveQueue(
    @query page?: int32,
    @query pageSize?: int32,
  ): Page<SampleReceipt> | ErrorResponse;

  // 挂载 I：M03.F07.I01
  @route("/issuance/queue")
  @get
  op listIssuanceQueue(
    @query page?: int32,
    @query pageSize?: int32,
  ): Page<SampleReceipt> | ErrorResponse;

  // 挂载 I：M03.F08.I01
  @route("/archived/queue")
  @get
  op listArchivedQueue(
    @query page?: int32,
    @query pageSize?: int32,
  ): Page<SampleReceipt> | ErrorResponse;
}