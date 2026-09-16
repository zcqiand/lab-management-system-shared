using TypeSpec.Http;

// M03.F03 样品管理（数据录入的样品维度）— CRUD
@route("/samples")
@tag("samples")
namespace Lab.Management.Shared.Samples {
  // M03.F03.I01 样品列表
  @get
  op listSamples(
    @query page?: int32,
    @query pageSize?: int32,
    @query receiptId?: string,
    @query keyword?: string,
  ): Page<Sample> | ErrorResponse;

  // M03.F03.I03 创建样品
  @post
  op createSample(@body body: CreateSampleRequest): Sample | ErrorResponse;

  // M03.F03.I02 样品详情
  @get
  @route("/{id}")
  op getSample(@path id: string): Sample | ErrorResponse;

  // M03.F03.I04 更新样品
  @put
  @route("/{id}")
  op updateSample(@path id: string, @body body: UpdateSampleRequest): Sample | ErrorResponse;

  // M03.F03.I05 删除样品
  @delete
  @route("/{id}")
  op deleteSample(@path id: string): void | ErrorResponse;
}