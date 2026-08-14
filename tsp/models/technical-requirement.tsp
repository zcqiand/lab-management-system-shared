using TypeSpec.Http;

// TechnicalRequirement — 技术要求维护（M04.F05）。
// 复合主键 (inspectionObjectCode, inspectionParameterCode, judgmentStandardCode)。
// brand/model/grade/spec 为 FK 引用 M04 四码表。
namespace Lab.Management.Shared;

enum RequirementValueType {
  numeric,
  string,
  range,
  formula,
  manual,
}

enum RequirementComparison {
  "≥",
  "≤",
  "=",
  range,
  eq,
}

enum RequirementVerificationStatus {
  draft,
  reviewed,
  verified,
  rejected,
}

enum RequirementJudgmentMode {
  automatic,
  manual,
}

model TechnicalRequirement {
  tenantId: string;
  inspectionObjectCode: string;
  inspectionParameterCode: string;
  judgmentStandardCode: string;

  conditions?: string;
  valueType: RequirementValueType;
  minValue?: int32;
  maxValue?: int32;
  targetValue?: string;
  expression?: string;
  unit?: string;
  comparison: RequirementComparison;
  judgmentMode: RequirementJudgmentMode;
  verificationStatus: RequirementVerificationStatus;

  clause?: string;
  sourcePage?: int32;
  sourceHash?: string;

  // FK 引用 inspection_brands/models/grades/specs（不强制，code 可空引用）
  "brand"?: string;
  "model"?: string;
  "grade"?: string;
  "spec"?: string;

  sieve?: string;
  remark?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateTechnicalRequirementRequest {
  inspectionObjectCode: string;
  inspectionParameterCode: string;
  judgmentStandardCode: string;
  conditions?: string;
  valueType?: RequirementValueType;
  minValue?: int32;
  maxValue?: int32;
  targetValue?: string;
  expression?: string;
  unit?: string;
  comparison?: RequirementComparison;
  judgmentMode?: RequirementJudgmentMode;
  verificationStatus?: RequirementVerificationStatus;
  clause?: string;
  sourcePage?: int32;
  sourceHash?: string;
  "brand"?: string;
  "model"?: string;
  "grade"?: string;
  "spec"?: string;
  sieve?: string;
  remark?: string;
  sortOrder?: int32;
}

model UpdateTechnicalRequirementRequest {
  conditions?: string;
  valueType?: RequirementValueType;
  minValue?: int32;
  maxValue?: int32;
  targetValue?: string;
  expression?: string;
  unit?: string;
  comparison?: RequirementComparison;
  judgmentMode?: RequirementJudgmentMode;
  verificationStatus?: RequirementVerificationStatus;
  clause?: string;
  sourcePage?: int32;
  sourceHash?: string;
  "brand"?: string;
  "model"?: string;
  "grade"?: string;
  "spec"?: string;
  sieve?: string;
  remark?: string;
  sortOrder?: int32;
}
