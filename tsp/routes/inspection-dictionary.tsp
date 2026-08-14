using TypeSpec.Http;

// M06.F01 检测专项 / M06.F02 检测项目 / M06.F03 检测参数 / M06.F04 检测标准
// 各自 CRUD + 对应 junction 的 link/unlink。
@route("/inspection")
@tag("inspection-dictionary")
namespace Lab.Management.Shared.InspectionDictionary {
  // ── M06.F01 检测专项 ──
  @get
  @route("/specialties")
  op listSpecialties(@query keyword?: string): InspectionSpecialty[] | ErrorResponse;

  @post
  @route("/specialties")
  op createSpecialty(@body body: CreateInspectionSpecialtyRequest): InspectionSpecialty | ErrorResponse;

  @put
  @route("/specialties/{code}")
  op updateSpecialty(@path code: string, @body body: UpdateInspectionSpecialtyRequest): InspectionSpecialty | ErrorResponse;

  @delete
  @route("/specialties/{code}")
  op deleteSpecialty(@path code: string): void | ErrorResponse;

  // ── M06.F02 检测项目 ──
  @get
  @route("/objects")
  op listObjects(
    @query inspectionSpecialtyCode?: string,
    @query keyword?: string,
  ): InspectionObject[] | ErrorResponse;

  @post
  @route("/objects")
  op createObject(@body body: CreateInspectionObjectRequest): InspectionObject | ErrorResponse;

  @put
  @route("/objects/{code}")
  op updateObject(@path code: string, @body body: UpdateInspectionObjectRequest): InspectionObject | ErrorResponse;

  @delete
  @route("/objects/{code}")
  op deleteObject(@path code: string): void | ErrorResponse;

  // ── M06.F03 检测参数 ──
  @get
  @route("/parameters")
  op listParameters(
    @query keyword?: string,
    @query sourceType?: InspectionParameterSourceType,
  ): InspectionParameter[] | ErrorResponse;

  @post
  @route("/parameters")
  op createParameter(@body body: CreateInspectionParameterRequest): InspectionParameter | ErrorResponse;

  @put
  @route("/parameters/{code}")
  op updateParameter(@path code: string, @body body: UpdateInspectionParameterRequest): InspectionParameter | ErrorResponse;

  @delete
  @route("/parameters/{code}")
  op deleteParameter(@path code: string): void | ErrorResponse;

  // ── M06.F04 检测标准 ──
  @get
  @route("/standards")
  op listStandards(
    @query keyword?: string,
    @query status?: InspectionStandardStatus,
  ): InspectionStandard[] | ErrorResponse;

  @post
  @route("/standards")
  op createStandard(@body body: CreateInspectionStandardRequest): InspectionStandard | ErrorResponse;

  @put
  @route("/standards/{code}")
  op updateStandard(@path code: string, @body body: UpdateInspectionStandardRequest): InspectionStandard | ErrorResponse;

  @delete
  @route("/standards/{code}")
  op deleteStandard(@path code: string): void | ErrorResponse;

  // ── junction link/unlink（专项-项目 / 项目-参数 / 项目-标准 / 标准-参数）──
  @post
  @route("/links/specialty-object")
  op linkSpecialtyObject(@body body: SpecialtyObjectLink): void | ErrorResponse;

  @delete
  @route("/links/specialty-object")
  op unlinkSpecialtyObject(@body body: SpecialtyObjectLink): void | ErrorResponse;

  @post
  @route("/links/object-parameter")
  op linkObjectParameter(@body body: ObjectParameterLink): void | ErrorResponse;

  @delete
  @route("/links/object-parameter")
  op unlinkObjectParameter(@body body: { inspectionObjectCode: string; inspectionParameterCode: string }): void | ErrorResponse;

  @post
  @route("/links/object-standard")
  op linkObjectStandard(@body body: ObjectStandardLink): void | ErrorResponse;

  @delete
  @route("/links/object-standard")
  op unlinkObjectStandard(@body body: { inspectionObjectCode: string; inspectionStandardCode: string; role: InspectionStandardRole }): void | ErrorResponse;

  @post
  @route("/links/standard-parameter")
  op linkStandardParameter(@body body: StandardParameterLink): void | ErrorResponse;

  @delete
  @route("/links/standard-parameter")
  op unlinkStandardParameter(@body body: StandardParameterLink): void | ErrorResponse;
}
