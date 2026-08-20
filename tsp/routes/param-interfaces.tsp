using TypeSpec.Http;

// M06.F08 参数界面 CRUD + link/unlink。
@route("/param-interfaces")
@tag("param-interfaces")
namespace Lab.Management.Shared.ParamInterfaces {
  @get
  op listParamInterfaces(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
  ): Page<ParamInterface> | ErrorResponse;

  @post
  op createParamInterface(@body body: CreateParamInterfaceRequest): ParamInterface | ErrorResponse;

  @get
  @route("/{code}")
  op getParamInterface(@path code: string): ParamInterface | ErrorResponse;

  @put
  @route("/{code}")
  op updateParamInterface(@path code: string, @body body: UpdateParamInterfaceRequest): ParamInterface | ErrorResponse;

  @delete
  @route("/{code}")
  op deleteParamInterface(@path code: string): void | ErrorResponse;

  // link：参数↔界面
  @post
  @route("/links")
  op linkParamInterface(@body body: ParamInterfaceLink): void | ErrorResponse;

  @delete
  @route("/links")
  op unlinkParamInterface(@body body: { inspectionParameterCode: string; paramInterfaceCode: string }): void | ErrorResponse;
}
