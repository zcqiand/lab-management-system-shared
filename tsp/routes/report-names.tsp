using TypeSpec.Http;

// M06.F07 报告名称 CRUD + 3 junction link/unlink。
@route("/report-names")
@tag("report-names")
namespace Lab.Management.Shared.ReportNames {
  // M06.F07.I01 报告名称列表
  @get
  op listReportNames(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
  ): Page<InspectionReportName> | ErrorResponse;

  // M06.F07.I03 创建报告名称
  @post
  op createReportName(@body body: CreateInspectionReportNameRequest): InspectionReportName | ErrorResponse;

  // M06.F07.I02 报告名称详情
  @get
  @route("/{code}")
  op getReportName(@path code: string): InspectionReportName | ErrorResponse;

  // M06.F07.I04 更新报告名称
  @put
  @route("/{code}")
  op updateReportName(@path code: string, @body body: UpdateInspectionReportNameRequest): InspectionReportName | ErrorResponse;

  // M06.F07.I05 删除报告名称
  @delete
  @route("/{code}")
  op deleteReportName(@path code: string): void | ErrorResponse;

  // junction：项目↔报告名称 / 报告名称↔标准(role) / 报告名称↔参数
  // （9 个 link 端点：POST/DELETE 挂 link I/unlink I，GET list 走 _exempt.tsp §2 豁免）
  // M06.F07.I06 项目↔报告名称 link
  @post
  @route("/links/object")
  op linkObjectReportName(@body body: ObjectReportNameLink): void | ErrorResponse;

  // M06.F04.I05 项目↔报告名称 unlink
  @delete
  @route("/links/object")
  op unlinkObjectReportName(@body body: { inspectionObjectCode: string; reportNameCode: string }): void | ErrorResponse;

  // 列表 GET 走 _exempt.tsp §2 豁免（POST/DELETE 已挂 link/unlink I）
  @get
  @route("/links/object")
  op listObjectReportNameLinks(
    @query inspectionObjectCode?: string,
    @query reportNameCode?: string,
  ): Page<ObjectReportNameLink> | ErrorResponse;

  // M06.F07.I07 报告名称↔标准 link
  @post
  @route("/links/standard")
  op linkReportNameStandard(@body body: ReportNameStandardLink): void | ErrorResponse;

  // M06.F04.I07 报告名称↔标准 unlink
  @delete
  @route("/links/standard")
  op unlinkReportNameStandard(@body body: { reportNameCode: string; inspectionStandardCode: string; role: InspectionStandardRole }): void | ErrorResponse;

  // 列表 GET 走 _exempt.tsp §2 豁免（POST/DELETE 已挂 link/unlink I）
  @get
  @route("/links/standard")
  op listReportNameStandardLinks(
    @query reportNameCode?: string,
    @query role?: InspectionStandardRole,
  ): Page<ReportNameStandardLink> | ErrorResponse;

  // M06.F07.I08 报告名称↔参数 link
  @post
  @route("/links/parameter")
  op linkReportNameParameter(@body body: ReportNameParameterLink): void | ErrorResponse;

  // M06.F04.I06 报告名称↔参数 unlink
  @delete
  @route("/links/parameter")
  op unlinkReportNameParameter(@body body: { reportNameCode: string; inspectionParameterCode: string }): void | ErrorResponse;

  // 列表 GET 走 _exempt.tsp §2 豁免（POST/DELETE 已挂 link/unlink I）
  @get
  @route("/links/parameter")
  op listReportNameParameterLinks(
    @query reportNameCode?: string,
    @query inspectionParameterCode?: string,
  ): Page<ReportNameParameterLink> | ErrorResponse;
}