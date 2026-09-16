using TypeSpec.Http;

// M06.F08 参数界面 CRUD + link/unlink。
@route("/param-interfaces")
@tag("param-interfaces")
namespace Lab.Management.Shared.ParamInterfaces {
  // M06.F08.I01 参数界面列表
  @get
  op listParamInterfaces(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
  ): Page<ParamInterface> | ErrorResponse;

  // M06.F08.I03 创建参数界面
  @post
  op createParamInterface(@body body: CreateParamInterfaceRequest): ParamInterface | ErrorResponse;

  // M06.F08.I02 参数界面详情
  @get
  @route("/{code}")
  op getParamInterface(@path code: string): ParamInterface | ErrorResponse;

  // M06.F08.I04 更新参数界面
  @put
  @route("/{code}")
  op updateParamInterface(@path code: string, @body body: UpdateParamInterfaceRequest): ParamInterface | ErrorResponse;

  // M06.F08.I05 删除参数界面
  @delete
  @route("/{code}")
  op deleteParamInterface(@path code: string): void | ErrorResponse;

  // link：参数↔界面（POST/DELETE/GET 三个端点，分别挂 link I/unlink I/list 豁免）
  // M06.F08.I06 参数↔界面 link
  @post
  @route("/links")
  op linkParamInterface(@body body: ParamInterfaceLink): void | ErrorResponse;

  // M06.F03.I07 参数↔界面 unlink
  @delete
  @route("/links")
  op unlinkParamInterface(@body body: { inspectionParameterCode: string; paramInterfaceCode: string }): void | ErrorResponse;

  // 列表 GET 走 _exempt.tsp §2 豁免（POST/DELETE 已挂 I06/I07，GET list 辅助）
  @get
  @route("/links")
  op listParamInterfaceLinks(
    @query inspectionParameterCode?: string,
    @query paramInterfaceCode?: string,
  ): Page<ParamInterfaceLink> | ErrorResponse;
}