using TypeSpec.Http;

// M04 基础数据四码表 — brand / model / spec / grade（结构完全一致）。
// code 主键；inspection_object_code 逻辑 FK 到 inspection_objects（M06，不强制）。
namespace Lab.Management.Shared;

model InspectionBrand {
  code: string;
  tenantId: string;
  inspectionObjectCode?: string;
  name: string;
  remark?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model InspectionModel {
  code: string;
  tenantId: string;
  inspectionObjectCode?: string;
  name: string;
  remark?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model InspectionSpec {
  code: string;
  tenantId: string;
  inspectionObjectCode?: string;
  name: string;
  remark?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

model InspectionGrade {
  code: string;
  tenantId: string;
  inspectionObjectCode?: string;
  name: string;
  remark?: string;
  sortOrder: int32;
  createdAt: string;
  updatedAt: string;
}

// 四码表共用 CRUD request（字段同构，复用一份）
model CreateCatalogEntryRequest {
  code: string;
  inspectionObjectCode?: string;
  name: string;
  remark?: string;
  sortOrder?: int32;
}

model UpdateCatalogEntryRequest {
  inspectionObjectCode?: string;
  name?: string;
  remark?: string;
  sortOrder?: int32;
}
