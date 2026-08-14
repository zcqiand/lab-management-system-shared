using TypeSpec.Http;

// M06.F08 参数界面：param_interfaces + param_interface_links。
namespace Lab.Management.Shared;

model ParamInterface {
  code: string;
  name?: string;
  componentPath: string;
  description?: string;
  isOfficial?: boolean;
  sortOrder: int32;
  config?: Record<unknown>;
  createdAt: string;
  updatedAt: string;
}

model CreateParamInterfaceRequest {
  code: string;
  name?: string;
  componentPath: string;
  description?: string;
  isOfficial?: boolean;
  sortOrder?: int32;
  config?: Record<unknown>;
}

model UpdateParamInterfaceRequest {
  name?: string;
  componentPath?: string;
  description?: string;
  isOfficial?: boolean;
  sortOrder?: int32;
  config?: Record<unknown>;
}

model ParamInterfaceLink {
  inspectionParameterCode: string;
  paramInterfaceCode: string;
  reportNameCode?: string;
  config?: Record<unknown>;
}
