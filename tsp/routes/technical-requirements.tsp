using TypeSpec.Http;

// M06.F06 技术要求维护 — CRUD（复合主键 object + parameter + judgment_standard）
// 列表按检测项目/参数/标准多维过滤；删除保护：被引用时拒绝。
// brand/model/grade/spec 引用 M04 码表，object/parameter/judgment_standard 引用 M06 字典。
@route("/technical-requirements")
@tag("technical-requirements")
namespace Lab.Management.Shared.TechnicalRequirements {
  @get
  op listTechnicalRequirements(
    @query inspectionObjectCode?: string,
    @query inspectionParameterCode?: string,
    @query judgmentStandardCode?: string,
    @query verificationStatus?: RequirementVerificationStatus,
  ): TechnicalRequirement[] | ErrorResponse;

  @post
  op createTechnicalRequirement(@body body: CreateTechnicalRequirementRequest): TechnicalRequirement | ErrorResponse;

  @get
  @route("/{inspectionObjectCode}/{inspectionParameterCode}/{judgmentStandardCode}")
  op getTechnicalRequirement(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
    @path judgmentStandardCode: string,
  ): TechnicalRequirement | ErrorResponse;

  @put
  @route("/{inspectionObjectCode}/{inspectionParameterCode}/{judgmentStandardCode}")
  op updateTechnicalRequirement(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
    @path judgmentStandardCode: string,
    @body body: UpdateTechnicalRequirementRequest,
  ): TechnicalRequirement | ErrorResponse;

  @delete
  @route("/{inspectionObjectCode}/{inspectionParameterCode}/{judgmentStandardCode}")
  op deleteTechnicalRequirement(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
    @path judgmentStandardCode: string,
  ): void | ErrorResponse;
}
