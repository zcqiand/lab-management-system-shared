using TypeSpec.Http;

// M06.F05 计算规则 CRUD（复合主键 object + parameter）。
@route("/calculation-rules")
@tag("calculation-rules")
namespace Lab.Management.Shared.CalculationRules {
  @get
  op listCalculationRules(
    @query inspectionObjectCode?: string,
    @query inspectionParameterCode?: string,
  ): CalculationRule[] | ErrorResponse;

  @post
  op createCalculationRule(@body body: CreateCalculationRuleRequest): CalculationRule | ErrorResponse;

  @get
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op getCalculationRule(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
  ): CalculationRule | ErrorResponse;

  @put
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op updateCalculationRule(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
    @body body: UpdateCalculationRuleRequest,
  ): CalculationRule | ErrorResponse;

  @delete
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op deleteCalculationRule(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
  ): void | ErrorResponse;
}
