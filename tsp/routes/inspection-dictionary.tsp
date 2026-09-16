using TypeSpec.Http;

// M06.F01 检测专项 / M06.F02 检测项目 / M06.F03 检测参数 / M06.F04 检测标准
// 各自 CRUD + 对应 junction 的 link/unlink。
@route("/inspection")
@tag("inspection-dictionary")
namespace Lab.Management.Shared.InspectionDictionary {
  // ── M06.F01 检测专项 ──
  // M06.F01.I01 专项列表
  @get
  @route("/specialties")
  op listSpecialties(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
  ): Page<InspectionSpecialty> | ErrorResponse;

  // M06.F01.I02 创建专项
  @post
  @route("/specialties")
  op createSpecialty(@body body: CreateInspectionSpecialtyRequest): InspectionSpecialty | ErrorResponse;

  // M06.F01.I03 更新专项
  @put
  @route("/specialties/{code}")
  op updateSpecialty(@path code: string, @body body: UpdateInspectionSpecialtyRequest): InspectionSpecialty | ErrorResponse;

  // M06.F01.I04 删除专项
  @delete
  @route("/specialties/{code}")
  op deleteSpecialty(@path code: string): void | ErrorResponse;

  // ── M06.F02 检测项目 ──
  // M06.F02.I01 项目列表
  @get
  @route("/objects")
  op listObjects(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionSpecialtyCode?: string,
    @query keyword?: string,
  ): Page<InspectionObject> | ErrorResponse;

  // M06.F02.I02 创建项目
  @post
  @route("/objects")
  op createObject(@body body: CreateInspectionObjectRequest): InspectionObject | ErrorResponse;

  // M06.F02.I03 更新项目
  @put
  @route("/objects/{code}")
  op updateObject(@path code: string, @body body: UpdateInspectionObjectRequest): InspectionObject | ErrorResponse;

  // M06.F02.I04 删除项目
  @delete
  @route("/objects/{code}")
  op deleteObject(@path code: string): void | ErrorResponse;

  // ── M06.F03 检测参数 ──
  // M06.F03.I01 参数列表
  @get
  @route("/parameters")
  op listParameters(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
    @query sourceType?: InspectionParameterSourceType,
  ): Page<InspectionParameter> | ErrorResponse;

  // M06.F03.I02 创建参数
  @post
  @route("/parameters")
  op createParameter(@body body: CreateInspectionParameterRequest): InspectionParameter | ErrorResponse;

  // M06.F03.I03 更新参数
  @put
  @route("/parameters/{code}")
  op updateParameter(@path code: string, @body body: UpdateInspectionParameterRequest): InspectionParameter | ErrorResponse;

  // M06.F03.I04 删除参数
  @delete
  @route("/parameters/{code}")
  op deleteParameter(@path code: string): void | ErrorResponse;

  // ── M06.F04 检测标准 ──
  // M06.F04.I01 标准列表
  @get
  @route("/standards")
  op listStandards(
    @query page?: int32,
    @query pageSize?: int32,
    @query keyword?: string,
    @query status?: InspectionStandardStatus,
  ): Page<InspectionStandard> | ErrorResponse;

  // M06.F04.I02 创建标准
  @post
  @route("/standards")
  op createStandard(@body body: CreateInspectionStandardRequest): InspectionStandard | ErrorResponse;

  // M06.F04.I03 更新标准
  @put
  @route("/standards/{code}")
  op updateStandard(@path code: string, @body body: UpdateInspectionStandardRequest): InspectionStandard | ErrorResponse;

  // M06.F04.I04 删除标准
  @delete
  @route("/standards/{code}")
  op deleteStandard(@path code: string): void | ErrorResponse;

  // ── junction link/unlink（专项-项目 / 项目-参数 / 项目-标准 / 标准-参数）──
  // M06.F02.I05 专项↔项目 link
  @post
  @route("/links/specialty-object")
  op linkSpecialtyObject(@body body: SpecialtyObjectLink): void | ErrorResponse;

  // M06.F02.I06 专项↔项目 unlink
  @delete
  @route("/links/specialty-object")
  op unlinkSpecialtyObject(@body body: SpecialtyObjectLink): void | ErrorResponse;

  // M06.F02.I09 专项↔项目 列表
  @get
  @route("/links/specialty-object")
  op listSpecialtyObjectLinks(
    @query inspectionSpecialtyCode?: string,
  ): Page<SpecialtyObjectLink> | ErrorResponse;

  // M06.F02.I07 项目↔参数 link
  @post
  @route("/links/object-parameter")
  op linkObjectParameter(@body body: ObjectParameterLink): void | ErrorResponse;

  // M06.F02.I08 项目↔参数 unlink
  @delete
  @route("/links/object-parameter")
  op unlinkObjectParameter(@body body: { inspectionObjectCode: string; inspectionParameterCode: string }): void | ErrorResponse;

  // M06.F02.I10 项目↔参数 列表
  @get
  @route("/links/object-parameter")
  op listObjectParameterLinks(
    @query inspectionObjectCode?: string,
    @query inspectionParameterCode?: string,
  ): Page<ObjectParameterLink> | ErrorResponse;

  // M06.F01.I05 项目↔标准 link
  @post
  @route("/links/object-standard")
  op linkObjectStandard(@body body: ObjectStandardLink): void | ErrorResponse;

  // M06.F01.I06 项目↔标准 unlink
  @delete
  @route("/links/object-standard")
  op unlinkObjectStandard(@body body: { inspectionObjectCode: string; inspectionStandardCode: string; role: InspectionStandardRole }): void | ErrorResponse;

  // M06.F01.I07 项目↔标准 列表
  @get
  @route("/links/object-standard")
  op listObjectStandardLinks(
    @query inspectionObjectCode?: string,
    @query role?: InspectionStandardRole,
  ): Page<ObjectStandardLink> | ErrorResponse;

  // M06.F03.I05 标准↔参数 link
  @post
  @route("/links/standard-parameter")
  op linkStandardParameter(@body body: StandardParameterLink): void | ErrorResponse;

  // M06.F03.I06 标准↔参数 unlink
  @delete
  @route("/links/standard-parameter")
  op unlinkStandardParameter(@body body: StandardParameterLink): void | ErrorResponse;

  // M06.F03.I08 标准↔参数 列表
  @get
  @route("/links/standard-parameter")
  op listStandardParameterLinks(
    @query inspectionStandardCode?: string,
    @query inspectionParameterCode?: string,
  ): Page<StandardParameterLink> | ErrorResponse;
}