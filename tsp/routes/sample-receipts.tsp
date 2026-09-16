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

  // M03.F01.I03 创建接样单
  @post
  op createReceipt(@body body: CreateSampleReceiptRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I02 接样单详情（接样信息+样品+检测数据）
  // 注：M03.F05.I02 / M03.F06.I02 / M03.F07.I02 / M03.F08.I02 / M03.F09.I01 共享此端点，详见 _exempt.tsp §3
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
  // 注：M03.F02.I02（客户端视角 anchor）共享此端点，详见 _exempt.tsp §3
  @put
  @route("/{id}/task")
  op assignTask(@path id: string, @body body: AssignTaskRequest): SampleReceipt | ErrorResponse;

  // M03.F01.I06 流程历史
  @get
  @route("/{id}/history")
  op getReceiptHistory(@path id: string): FlowHistoryEntry[] | ErrorResponse;
}
