using TypeSpec.Http;

// M06.F05 计算方法（复合主键 object + parameter）。
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

model CalculationMethod {
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

model CreateCalculationMethodRequest {
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

model UpdateCalculationMethodRequest {
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
