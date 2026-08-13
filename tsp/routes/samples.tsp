using TypeSpec.Http;

// M03.F03 样品管理（数据录入的样品维度）— CRUD
@route("/samples")
@tag("samples")
namespace Lab.Management.Shared.Samples {
  @get
  op listSamples(
    @query page?: int32,
    @query pageSize?: int32,
    @query receiptId?: string,
    @query keyword?: string,
  ): Page<Sample> | ErrorResponse;

  @post
  op createSample(@body body: CreateSampleRequest): Sample | ErrorResponse;

  @get
  @route("/{id}")
  op getSample(@path id: string): Sample | ErrorResponse;

  @put
  @route("/{id}")
  op updateSample(@path id: string, @body body: UpdateSampleRequest): Sample | ErrorResponse;

  @delete
  @route("/{id}")
  op deleteSample(@path id: string): void | ErrorResponse;
}
