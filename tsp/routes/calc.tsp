using TypeSpec.Http;

// M06.F10 公式求值与记录复现（R2 纯增，2026-11-22 人批「两点处理」）。
// evaluate = 保存前预览（含 verdict 预览）；records/{recordId} = 服务读库复算，
// 只读不落库（formulaSnapshot 为复现键，spec 裁量 1）。
@route("/calc")
@tag("calc")
namespace Lab.Management.Shared.Calc {
  // M06.F10.I01 公式求值（保存前预览，含 verdict 预览）
  @post
  @route("/evaluate")
  op evaluateCalc(@body body: CalcEvaluateRequest): CalcEvaluationResult | ErrorResponse;

  // M06.F10.I02 检测记录复现（读 test_records + calc_methods 复算，只读不落库）
  @get
  @route("/records/{recordId}")
  op getCalcRecord(@path recordId: string): CalcEvaluationResult | ErrorResponse;
}
