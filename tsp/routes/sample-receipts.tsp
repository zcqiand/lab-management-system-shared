using TypeSpec.Http;

// M03.F01 接样管理 + M03.F02 任务分配 + M03.F09 接样单详情 + M03.F01/F02/F03/F05/F06/F07/F08 流程动作
// 报告字段已并入接样单。流程动作（含早期 3 阶段 submit/return/withdraw + 报告 4 阶段 act/queue）原独立 report-flow.tsp 于 2026-09-17 合并至此。
// 早期 3 阶段按 action 拆 9 端点；报告 4 阶段共用 act（submit/return via body.action）+ 4 list*queue + 2 批量（review batch-submit/batch-return）。
@route("/receipts")
@tag("receipts")
namespace Lab.Management.Shared.Receipts {
  // M03.F01.I01 列表（三态过滤：全部/未提交/已提交）
  @get
  op listReceipts(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
    @query contractId?: string,
    @query flowStatus?: FlowStatus,
  ): Page<SampleReceipt> | ErrorResponse;

  // M03.F01.I03 创建接样单
  @post
  op createReceipt(@body body: CreateSampleReceiptRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I02 接样单详情（接样信息+样品+检测数据）
  // 注：F05.I02 / F06.I02 / F07.I02 / F08.I02 / F09.I01 均走 type=按钮（前端打开详情页动作），1:1 端点只挂 I02
  @get
  @route("/{id}")
  op getReceipt(@path id: string): SampleReceipt | ErrorResponse;

  // M03.F01.I04 更新接样单
  @put
  @route("/{id}")
  op updateReceipt(@path id: string, @body body: UpdateSampleReceiptRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I05 删除接样单
  @delete
  @route("/{id}")
  op deleteReceipt(@path id: string): void | ErrorResponse;

  // M03.F02.I01 任务分配 / 取消
  // 注：F02.I02（客户端视角 anchor）走 type=按钮（前端弹窗 UI 动作），1:1 端点只挂 I01
  @put
  @route("/{id}/task")
  op assignTask(@path id: string, @body body: AssignTaskRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I06 流程历史
  @get
  @route("/{id}/history")
  op getReceiptHistory(@path id: string): FlowHistoryEntry[] | ErrorResponse;

  // ============================================================
  // 流程动作 — 原 report-flow.tsp（2026-09-17 合并）
  // 早期 3 阶段按 action 拆 9 端点（F01/F02/F03）；
  // 报告 4 阶段共用 act 端点（submit/return via body.action，F05/F06/F07/F08）；
  // 报告 4 阶段 list*queue（F05/F06/F07/F08）；
  // 报告审核批量（F05 batch-submit/batch-return）。
  // ============================================================

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
