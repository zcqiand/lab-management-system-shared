using TypeSpec.Http;

// M06.F07 报告名称 CRUD + 3 junction link/unlink。
@route("/report-names")
@tag("report-names")
namespace Lab.Management.Shared.ReportNames {
  @get
  op listReportNames(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
  ): Page<InspectionReportName> | ErrorResponse;

  @post
  op createReportName(@body body: CreateInspectionReportNameRequest): InspectionReportName | ErrorResponse;

  @get
  @route("/{code}")
  op getReportName(@path code: string): InspectionReportName | ErrorResponse;

  @put
  @route("/{code}")
  op updateReportName(@path code: string, @body body: UpdateInspectionReportNameRequest): InspectionReportName | ErrorResponse;

  @delete
  @route("/{code}")
  op deleteReportName(@path code: string): void | ErrorResponse;

  // junction：项目↔报告名称 / 报告名称↔标准(role) / 报告名称↔参数
  @post
  @route("/links/object")
  op linkObjectReportName(@body body: ObjectReportNameLink): void | ErrorResponse;

  @delete
  @route("/links/object")
  op unlinkObjectReportName(@body body: { inspectionObjectCode: string; reportNameCode: string }): void | ErrorResponse;

  @get
  @route("/links/object")
  op listObjectReportNameLinks(
    @query inspectionObjectCode?: string,
    @query reportNameCode?: string,
  ): Page<ObjectReportNameLink> | ErrorResponse;

  @post
  @route("/links/standard")
  op linkReportNameStandard(@body body: ReportNameStandardLink): void | ErrorResponse;

  @delete
  @route("/links/standard")
  op unlinkReportNameStandard(@body body: { reportNameCode: string; inspectionStandardCode: string; role: InspectionStandardRole }): void | ErrorResponse;

  @get
  @route("/links/standard")
  op listReportNameStandardLinks(
    @query reportNameCode?: string,
    @query role?: InspectionStandardRole,
  ): Page<ReportNameStandardLink> | ErrorResponse;

  @post
  @route("/links/parameter")
  op linkReportNameParameter(@body body: ReportNameParameterLink): void | ErrorResponse;

  @delete
  @route("/links/parameter")
  op unlinkReportNameParameter(@body body: { reportNameCode: string; inspectionParameterCode: string }): void | ErrorResponse;

  @get
  @route("/links/parameter")
  op listReportNameParameterLinks(
    @query reportNameCode?: string,
    @query inspectionParameterCode?: string,
  ): Page<ReportNameParameterLink> | ErrorResponse;
}
