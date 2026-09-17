using TypeSpec.Http;

// M03.F01 接样管理 + M03.F02 任务分配 + M03.F09 接样单详情 + M03.F01/F02/F03/F05/F06/F07/F08 流程动作
// 报告字段已并入接样单。流程动作 7 阶段全 act 模式（F01/F02/F03/F05/F06/F07/F08 每阶段 1 个 act 端点，body.action={SUBMIT|RETURN|WITHDRAW}）；
// 原独立 report-flow.tsp 于 2026-09-17 合并至此。原早期 3 阶段 9 端点（每阶段 submit/return/withdraw）+ 报告 4 阶段 act + 4 list*queue + 2 批量（review batch-submit/batch-return 已废）已收敛。
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
  // 注：F05.I02 / F06.I02 / F07.I02 / F08.I02 / F09.I01 / F09.I02（2026-09-17 标 已废弃）均走 type=按钮/页面（前端打开详情页动作），1:1 端点只挂 I02
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
  // 注：F02.I02 / F02.I03（2026-09-17 标 已废弃）原本就是客户端视角 anchor，1:1 端点只挂 I01；无独立 .tsp 端点定义可删，仅在 function-tree.md / alignment.json 标 已废弃
  @put
  @route("/{id}/task")
  op assignTask(@path id: string, @body body: AssignTaskRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I06 流程历史
  @get
  @route("/{id}/history")
  op getReceiptHistory(@path id: string): FlowHistoryEntry[] | ErrorResponse;

  // ============================================================
  // 流程动作 — 原 report-flow.tsp（2026-09-17 合并）
  // 7 阶段全 act 模式（F01/F02/F03/F05/F06/F07/F08，每阶段 1 个 act 端点 body.action={SUBMIT|RETURN|WITHDRAW}）；
  // 报告 4 阶段 list*queue（F05/F06/F07/F08.I01）2026-09-17 已删——队列数据走前端；
  // 报告审核批量（F05 batch-submit/batch-return）2026-09-17 已删 op。
  // ============================================================

  // 接样阶段流程动作（2026-09-17 合并为 act）
  // 旧 F01.I08 submit / F01.I09 return / F01.I10 withdraw 3 端点合并为单一 act 端点
  // 新结构：F01.I08 提交 / F01.I09 退回 / F01.I10 撤回 共用 act 端点（POST /receiving/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F01.I08 / F01.I09 / F01.I10
  // ADR-0036 fuzz:skip：流程动作 7 阶段 act 模式（body.action=SUBMIT/RETURN/WITHDRAW），
  // 状态机 + 顺序决定结果，Schemathesis 跳过；语义由 vitest 套件测
  @route("/receiving/act")
  @post
  // fuzz:skip
  op actFlowReceiving(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 任务分配阶段流程动作（2026-09-17 合并为 act）
  // 旧 F02.I05 submit / F02.I06 return / F02.I07 withdraw 3 端点合并为单一 act 端点
  // 新结构：F02.I05 提交 / F02.I06 退回 / F02.I07 撤回 共用 act 端点（POST /assigning/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F02.I05 / F02.I06 / F02.I07
  @route("/assigning/act")
  @post
  op actFlowAssigning(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 数据录入阶段流程动作（2026-09-17 合并为 act）
  // 旧 F03.I12 submit / F03.I13 return / F03.I14 withdraw 3 端点合并为单一 act 端点
  // 新结构：F03.I12 提交 / F03.I13 退回 / F03.I14 撤回 共用 act 端点（POST /data-entry/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F03.I12 / F03.I13 / F03.I14
  @route("/data-entry/act")
  @post
  op actFlowDataEntry(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告审核阶段流程动作（2026-09-17 重整 → 4 阶段全 act 合并）
  // 旧 F05.I03 act（submit/return 共端点，body.action 区分）扩展为 3 动作端点（SUBMIT/RETURN/WITHDRAW）
  // 旧 F05.I05 batch-submit / F05.I06 batch-return 已废弃并删 op
  // 新结构：F05.I07 提交 / F05.I08 退回 / F05.I09 撤回 共用同一 act 端点（POST /review/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F05.I07 / F05.I08 / F05.I09（提交/退回/撤回 共端点，body.action 区分）
  @route("/review/act")
  @post
  op actFlowReview(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告批准阶段流程动作（2026-09-17 重整 → 4 阶段全 act 合并）
  // 旧 F06.I03 act 扩展为 3 动作端点（SUBMIT/RETURN/WITHDRAW）
  // 新结构：F06.I05 提交 / F06.I06 退回 / F06.I07 撤回 共用同一 act 端点（POST /approve/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F06.I05 / F06.I06 / F06.I07
  @route("/approve/act")
  @post
  op actFlowApprove(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告发放阶段流程动作（2026-09-17 重整 → 4 阶段全 act 合并）
  // 旧 F07.I03 act 扩展为 3 动作端点
  // 新结构：F07.I05 提交 / F07.I06 退回 / F07.I07 撤回 共用同一 act 端点（POST /issuance/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F07.I05 / F07.I06 / F07.I07
  @route("/issuance/act")
  @post
  op actFlowIssuance(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 报告归档阶段流程动作（2026-09-17 重整 → 4 阶段全 act 合并）
  // 旧 F08.I03 act 扩展为 3 动作端点
  // 新结构：F08.I05 提交 / F08.I06 退回 / F08.I07 撤回 共用同一 act 端点（POST /archived/act with body.action={SUBMIT|RETURN|WITHDRAW}）
  // 挂载 I：M03.F08.I05 / F08.I06 / F08.I07
  @route("/archived/act")
  @post
  op actFlowArchived(@body body: FlowActionRequest): FlowActionResult[] | ErrorResponse;

  // 各阶段队列端点（4 个：F05/F06/F07/F08.I01）已于 2026-09-17 删除——队列数据走前端
  // FlowQueue 共享端点 + Receipts 流式筛选，不再需要 per-stage 队列端点。
  // 对应 function-tree I01 状态 → 已废弃。
}
