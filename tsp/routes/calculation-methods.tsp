using TypeSpec.Http;

// M06.F05 计算方法 CRUD（复合主键 object + parameter）。
@route("/calculation-methods")
@tag("calculation-methods")
namespace Lab.Management.Shared.CalculationMethods {
  @get
  op listCalculationMethods(
    @query inspectionObjectCode?: string,
    @query inspectionParameterCode?: string,
  ): CalculationMethod[] | ErrorResponse;

  @post
  op createCalculationMethod(@body body: CreateCalculationMethodRequest): CalculationMethod | ErrorResponse;

  @get
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op getCalculationMethod(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
  ): CalculationMethod | ErrorResponse;

  @put
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op updateCalculationMethod(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
    @body body: UpdateCalculationMethodRequest,
  ): CalculationMethod | ErrorResponse;

  @delete
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op deleteCalculationMethod(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
  ): void | ErrorResponse;
}
