using TypeSpec.Http;

// M06 检测能力字典：专项 / 项目 / 参数 / 标准 + 4 junction。
namespace Lab.Management.Shared;

enum InspectionStandardStatus {
  active,
  superseded,
  draft,
}

enum InspectionParameterSourceType {
  official,
  custom,
}

enum QualificationLevel {
  QUALIFIED,
  RESTRICTED,
}

enum InspectionStandardRole {
  TESTING,
  JUDGMENT,
}

// === M06.F01 检测专项 ===
model InspectionSpecialty {
  code: string;
  officialNo: string;
  name: string;
  isOfficial: boolean;
  enabled: boolean;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateInspectionSpecialtyRequest {
  code: string;
  officialNo: string;
  name: string;
  isOfficial?: boolean;
  enabled?: boolean;
  sortOrder?: int32;
}

model UpdateInspectionSpecialtyRequest {
  officialNo?: string;
  name?: string;
  isOfficial?: boolean;
  enabled?: boolean;
  sortOrder?: int32;
}

// === M06.F02 检测项目 ===
model InspectionObject {
  code: string;
  inspectionSpecialtyCode: string;
  sourceProjectNo: string;
  sourceProjectName: string;
  name: string;
  isOptionalForQualification: boolean;
  isOfficial: boolean;
  enabled: boolean;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateInspectionObjectRequest {
  code: string;
  inspectionSpecialtyCode: string;
  sourceProjectNo: string;
  sourceProjectName: string;
  name: string;
  isOptionalForQualification?: boolean;
  isOfficial?: boolean;
  enabled?: boolean;
  sortOrder?: int32;
}

model UpdateInspectionObjectRequest {
  inspectionSpecialtyCode?: string;
  sourceProjectNo?: string;
  sourceProjectName?: string;
  name?: string;
  isOptionalForQualification?: boolean;
  isOfficial?: boolean;
  enabled?: boolean;
  sortOrder?: int32;
}

// === M06.F03 检测参数 ===
model InspectionParameter {
  code: string;
  name: string;
  rawName: string;
  canonicalName: string;
  methodText?: string;
  aliases: string[];
  unit?: string;
  sourceType: InspectionParameterSourceType;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateInspectionParameterRequest {
  code: string;
  name: string;
  rawName: string;
  canonicalName: string;
  methodText?: string;
  aliases?: string[];
  unit?: string;
  sourceType?: InspectionParameterSourceType;
  sortOrder?: int32;
}

model UpdateInspectionParameterRequest {
  name?: string;
  rawName?: string;
  canonicalName?: string;
  methodText?: string;
  aliases?: string[];
  unit?: string;
  sourceType?: InspectionParameterSourceType;
  sortOrder?: int32;
}

// === M06.F04 检测标准 ===
model InspectionStandard {
  code: string;
  name: string;
  version?: string;
  status: InspectionStandardStatus;
  sourceDocumentId?: string;
  sourceHash?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateInspectionStandardRequest {
  code: string;
  name: string;
  version?: string;
  status?: InspectionStandardStatus;
  sourceDocumentId?: string;
  sourceHash?: string;
  sortOrder?: int32;
}

model UpdateInspectionStandardRequest {
  name?: string;
  version?: string;
  status?: InspectionStandardStatus;
  sourceDocumentId?: string;
  sourceHash?: string;
  sortOrder?: int32;
}

// === junction rows（专项-项目 / 项目-参数 / 项目-标准 / 标准-参数）===
model SpecialtyObjectLink {
  inspectionSpecialtyCode: string;
  inspectionObjectCode: string;
  remark?: string;
}

model ObjectParameterLink {
  inspectionObjectCode: string;
  inspectionParameterCode: string;
  qualificationLevel: QualificationLevel;
  sourcePage?: int32;
  remark?: string;
}

model ObjectStandardLink {
  inspectionObjectCode: string;
  inspectionStandardCode: string;
  role: InspectionStandardRole;
  remark?: string;
}

model StandardParameterLink {
  inspectionStandardCode: string;
  inspectionParameterCode: string;
}
