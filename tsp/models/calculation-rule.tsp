using TypeSpec.Http;

// M06.F05 计算规则（复合主键 object + parameter）。
namespace Lab.Management.Shared;

enum CalculationAlgorithmType {
  simple_avg,
  compressive_strength,
  flexural_strength,
  steel_tensile,
  formula,
  manual,
  auto_calc_ratio,
}

model CalculationRule {
  inspectionObjectCode: string;
  inspectionParameterCode: string;
  testingStandardCode?: string;
  reportNameCode?: string;
  algorithmType: CalculationAlgorithmType;
  specimenCount: int32;
  formula?: string;
  conditions?: string;
  roundingRule?: string;
  remark?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateCalculationRuleRequest {
  inspectionObjectCode: string;
  inspectionParameterCode: string;
  testingStandardCode?: string;
  reportNameCode?: string;
  algorithmType?: CalculationAlgorithmType;
  specimenCount?: int32;
  formula?: string;
  conditions?: string;
  roundingRule?: string;
  remark?: string;
  sortOrder?: int32;
}

model UpdateCalculationRuleRequest {
  testingStandardCode?: string;
  reportNameCode?: string;
  algorithmType?: CalculationAlgorithmType;
  specimenCount?: int32;
  formula?: string;
  conditions?: string;
  roundingRule?: string;
  remark?: string;
  sortOrder?: int32;
}
