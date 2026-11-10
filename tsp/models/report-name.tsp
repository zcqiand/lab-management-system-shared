using TypeSpec.Http;

// M06.F07 报告名称 + 3 junction。
// 2026-11-10 人裁：extFields（含 ExtFieldDef 族）退役——样品信息扩展属性的采集
// 结构移交 ReportNameInterface（schema 驱动，参考 ParamInterface 同构）。
namespace Lab.Management.Shared;

model InspectionReportName {
  code: string;
  name: string;
  fullName?: string;
  templatePath?: string;
  summaryName?: string;
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
  description?: string;
  sortOrder?: int32;
}

model UpdateInspectionReportNameRequest {
  name?: string;
  fullName?: string;
  templatePath?: string;
  summaryName?: string;
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

// 报告名称级样品扩展属性界面（2026-11-10 人裁）：config 形状与 ParamInterface
// 同款（{ title?, fields[], computed?, params? }），数据面落在 samples.ext。
model ReportNameInterface {
  code: string;
  name?: string;
  description?: string;
  @doc("表单结构版本，结构迭代升级用，服务端管理，缺省 1。")
  version: int32;
  @doc("表单结构定义（Schema）：{ title?, fields[], computed?, params? }。")
  config?: Record<unknown>;
  createdAt: string;
  updatedAt: string;
}

model CreateReportNameInterfaceRequest {
  code: string;
  name?: string;
  description?: string;
  version?: int32;
  config?: Record<unknown>;
}

model UpdateReportNameInterfaceRequest {
  name?: string;
  description?: string;
  version?: int32;
  config?: Record<unknown>;
}

model ReportNameInterfaceLink {
  reportNameCode: string;
  reportNameInterfaceCode: string;
}
