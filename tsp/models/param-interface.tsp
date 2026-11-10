using TypeSpec.Http;

// M06.F08 参数界面：param_interfaces + param_interface_links。
namespace Lab.Management.Shared;

// ADR-0056：componentPath 退役（动态渲染器按 config schema 渲染，不再按组件路由）；
// config 语义升级为表单结构定义（fields 采集面 + computed 算法域引用 + params 算法入参）；
// 数据面在 TestRecord.data。
// 2026-11-10 追加裁定：isOfficial/sortOrder 退役（接口不再分官方/自建、排序交前端/清单）；
// link 去 config，增 inspectionStandardCode（绑定检测依据，可空=不限）。
model ParamInterface {
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

model CreateParamInterfaceRequest {
  code: string;
  name?: string;
  description?: string;
  version?: int32;
  config?: Record<unknown>;
}

model UpdateParamInterfaceRequest {
  name?: string;
  description?: string;
  version?: int32;
  config?: Record<unknown>;
}

model ParamInterfaceLink {
  inspectionParameterCode: string;
  paramInterfaceCode: string;
  reportNameCode?: string;
  @doc("绑定的检测依据 code，可空=不限依据。")
  inspectionStandardCode?: string;
}
