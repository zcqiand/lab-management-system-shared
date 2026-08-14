using TypeSpec.Http;

// M06.F07 报告名称 + 3 junction。
namespace Lab.Management.Shared;

model ExtFieldDef {
  key: string;
  label: string;
  type: ExtFieldDefType;
  required?: boolean;
  options?: string[];
  tag?: string;
  source?: ExtFieldDefSource;
}

enum ExtFieldDefType {
  text,
  number,
  date,
  select,
}

enum ExtFieldDefSource {
  sample,
  receipt,
}

model InspectionReportName {
  code: string;
  name: string;
  fullName?: string;
  templatePath?: string;
  summaryName?: string;
  extFields?: ExtFieldDef[];
  description?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model CreateInspectionReportNameRequest {
  code: string;
  name: string;
  fullName?: string;
  templatePath?: string;
  summaryName?: string;
  extFields?: ExtFieldDef[];
  description?: string;
  sortOrder?: int32;
}

model UpdateInspectionReportNameRequest {
  name?: string;
  fullName?: string;
  templatePath?: string;
  summaryName?: string;
  extFields?: ExtFieldDef[];
  description?: string;
  sortOrder?: int32;
}

// junction：项目↔报告名称 / 报告名称↔标准(role) / 报告名称↔参数
model ObjectReportNameLink {
  inspectionObjectCode: string;
  reportNameCode: string;
  remark?: string;
}

model ReportNameStandardLink {
  reportNameCode: string;
  inspectionStandardCode: string;
  role: InspectionStandardRole;
  remark?: string;
}

model ReportNameParameterLink {
  reportNameCode: string;
  inspectionParameterCode: string;
  remark?: string;
}
