using TypeSpec.Http;

// M06.F05 计算方法 CRUD（复合主键 object + parameter）。
@route("/calculation-methods")
@tag("calculation-methods")
namespace Lab.Management.Shared.CalculationMethods {
  // M06.F05.I01 计算方法列表
  @get
  op listCalculationMethods(
    @query inspectionObjectCode?: string,
    @query inspectionParameterCode?: string,
  ): CalculationMethod[] | ErrorResponse;

  // M06.F05.I03 创建计算方法
  @post
  op createCalculationMethod(@body body: CreateCalculationMethodRequest): CalculationMethod | ErrorResponse;

  // M06.F05.I02 计算方法详情
  @get
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op getCalculationMethod(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
  ): CalculationMethod | ErrorResponse;

  // M06.F05.I04 更新计算方法
  @put
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op updateCalculationMethod(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
    @body body: UpdateCalculationMethodRequest,
  ): CalculationMethod | ErrorResponse;

  // M06.F05.I05 删除计算方法
  @delete
  @route("/{inspectionObjectCode}/{inspectionParameterCode}")
  op deleteCalculationMethod(
    @path inspectionObjectCode: string,
    @path inspectionParameterCode: string,
  ): void | ErrorResponse;
}