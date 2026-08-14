using TypeSpec.Http;

// Sample — 样品（M03.F02/F03）。model/spec/grade/brand 为逻辑字符串引用。
namespace Lab.Management.Shared;

model Sample {
  id: string;
  tenantId: string;
  receiptId: string;
  sampleCode: string;
  sampleName?: string;

  // 逻辑 FK → inspection_models/specs/grades/brands（M04），不强制
  "model"?: string;
  specification?: string;
  grade?: string;
  brand?: string;

  manufacturer?: string;
  structuralPart?: string;
  representQuantity?: string;
  sampleQuantity?: string;
  batchNumber?: string;
  supplyUnit?: string;
  arrivalDate?: string;
  samplingDate?: string;
  curingCondition?: string;
  age?: string;

  ext: Record<string>;

  remark?: string;

  createdAt: string;
  updatedAt: string;
}

model CreateSampleRequest {
  receiptId: string;
  sampleCode: string;
  sampleName?: string;
  "model"?: string;
  specification?: string;
  grade?: string;
  brand?: string;
  manufacturer?: string;
  structuralPart?: string;
  representQuantity?: string;
  sampleQuantity?: string;
  batchNumber?: string;
  supplyUnit?: string;
  arrivalDate?: string;
  samplingDate?: string;
  curingCondition?: string;
  age?: string;
  ext?: Record<string>;
  remark?: string;
}

model UpdateSampleRequest {
  receiptId?: string;
  sampleCode?: string;
  sampleName?: string;
  "model"?: string;
  specification?: string;
  grade?: string;
  brand?: string;
  manufacturer?: string;
  structuralPart?: string;
  representQuantity?: string;
  sampleQuantity?: string;
  batchNumber?: string;
  supplyUnit?: string;
  arrivalDate?: string;
  samplingDate?: string;
  curingCondition?: string;
  age?: string;
  ext?: Record<string>;
  remark?: string;
}
