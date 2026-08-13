using TypeSpec.Http;

// M03.F01 接样管理 + M03.F02 任务分配 + M03.F09 接样单详情
// 报告字段已并入接样单。流程动作见 report-flow.tsp。
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

  // M03.F01.I02 创建
  @post
  op createReceipt(@body body: CreateSampleReceiptRequest): SampleReceipt | ErrorResponse;

  // M03.F09 接样单详情（接样信息+样品+检测数据）
  @get
  @route("/{id}")
  op getReceipt(@path id: string): SampleReceipt | ErrorResponse;

  // M03.F01.I03 编辑
  @put
  @route("/{id}")
  op updateReceipt(@path id: string, @body body: UpdateSampleReceiptRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I04 删除
  @delete
  @route("/{id}")
  op deleteReceipt(@path id: string): void | ErrorResponse;

  // M03.F02 任务分配 / 取消
  @put
  @route("/{id}/task")
  op assignTask(@path id: string, @body body: AssignTaskRequest): SampleReceipt | ErrorResponse;

  // M03.F09 流程历史
  @get
  @route("/{id}/history")
  op getReceiptHistory(@path id: string): FlowHistoryEntry[] | ErrorResponse;
}
