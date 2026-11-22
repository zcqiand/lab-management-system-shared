using TypeSpec.Http;

// R2 纯增 calc 段模型（2026-11-22 人批「两点处理」）——公式求值 + 记录复现。
// 引擎内核语义镜像 rules 仓 src/lib/calc-engine/types.ts（CalcInput/CalcOutput），
// verdict 语义镜像 nextjs autoVerdict（cement-strength.ts:90-105）。

model CalcError {
  code: ("FORMULA_PARSE_ERROR" | "CONTEXT_KEY_MISSING" | "DIVIDE_BY_ZERO");
  /** 语法错位置（FORMULA_PARSE_ERROR 专用） */
  position?: int32;
  message: string;
  /** 试件组序（逐组错误专用） */
  group?: int32;
}

/** 求值时的判定参照（technical-requirements 行的判定子集） */
model CalcTechReqRef {
  comparison: ("≥" | "≤" | "range");
  minValue?: decimal;
  maxValue?: decimal;
  valueType?: ("numeric" | "string" | "range" | "formula" | "manual");
}

model CalcEvaluateRequest {
  /** calc 表 formula 列原文 */
  formula: string;
  /** 每组试件一个上下文（装配器产物） */
  contexts: Record<float64>[];
  /** 判定参照；缺省 = 不产 verdict（返回 ""） */
  techReq?: CalcTechReqRef;
}

model CalcEvaluationResult {
  /** 逐组结果；无效组 = null（非 0，不兜 0） */
  strengths: (float64 | null)[];
  /** 有效组全精度均值；无有效组 = null（引擎不修约，展示口径归调用侧） */
  mean: float64 | null;
  errors: CalcError[];
  /** "合格" | "不合格" | ""（mean null / techReq 缺失 / comparison 不命中 → ""） */
  verdict: string;
}
