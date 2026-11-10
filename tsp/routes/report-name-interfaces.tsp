using TypeSpec.Http;

// 报告名称级样品扩展属性界面 CRUD + link/unlink（2026-11-10 人裁，参考 param-interfaces 同构；
// 取代 inspection_report_names.ext_fields）。
@route("/report-name-interfaces")
@tag("report-name-interfaces")
namespace Lab.Management.Shared.ReportNameInterfaces {
  // M06.F09.I01 界面列表
  @get
  @doc("分页：当前实现仅回显不切片，参照实现返回全量，无分页语义（pageSize 同）。")
  op listReportNameInterfaces(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
  ): Page<ReportNameInterface> | ErrorResponse;

  // M06.F09.I03 创建界面
  @post
  op createReportNameInterface(@body body: CreateReportNameInterfaceRequest): ReportNameInterface | ErrorResponse;

  // M06.F09.I02 界面详情
  @get
  @route("/{code}")
  op getReportNameInterface(@path code: string): ReportNameInterface | ErrorResponse;

  // M06.F09.I04 更新界面
  @put
  @route("/{code}")
  op updateReportNameInterface(@path code: string, @body body: UpdateReportNameInterfaceRequest): ReportNameInterface | ErrorResponse;

  // M06.F09.I05 删除界面（级联删 links）
  @delete
  @route("/{code}")
  op deleteReportNameInterface(@path code: string): void | ErrorResponse;

  // link：报告名称↔界面（POST/DELETE/GET 三端点；GET list 走 ADR-0034 §3 自然豁免）
  // M06.F09.I06 报告名称↔界面 link
  @post
  @route("/links")
  op linkReportNameInterface(@body body: ReportNameInterfaceLink): void | ErrorResponse;

  // M06.F09.I07 报告名称↔界面 unlink
  @delete
  @route("/links")
  op unlinkReportNameInterface(@body body: { reportNameCode: string; reportNameInterfaceCode: string }): void | ErrorResponse;

  @get
  @route("/links")
  op listReportNameInterfaceLinks(
    @query reportNameCode?: string,
    @query reportNameInterfaceCode?: string,
  ): Page<ReportNameInterfaceLink> | ErrorResponse;
}
