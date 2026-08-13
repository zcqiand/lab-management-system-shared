using TypeSpec.Http;

// Contract — 合同/委托（M02.F01）。平台级（实验室单租户，无 tenant_id）。
namespace Lab.Management.Shared;

enum ContractStatus {
  active,
  archived,
}

model Contract {
  id: string;

  contractCode: string;

  clientUnit: string;

  projectName: string;

  projectLocation?: string;

  constructionUnit: string;

  // 逻辑 FK → inspection_specialties（M06 已废弃，不强制）
  inspectionSpecialtyCode?: string;

  buildingUnit?: string;
  supervisorUnit?: string;
  inspectionPerson?: string;
  inspectionPhone?: string;

  witnessUnit: string;
  witness: string;
  witnessPhone?: string;

  contactPerson?: string;
  contactPhone?: string;

  entrustedDate?: string;

  status: ContractStatus;

  createdAt: string;
  updatedAt: string;
}

model CreateContractRequest {
  contractCode: string;
  clientUnit: string;
  projectName: string;
  projectLocation?: string;
  constructionUnit: string;
  inspectionSpecialtyCode?: string;
  buildingUnit?: string;
  supervisorUnit?: string;
  inspectionPerson?: string;
  inspectionPhone?: string;
  witnessUnit: string;
  witness: string;
  witnessPhone?: string;
  contactPerson?: string;
  contactPhone?: string;
  entrustedDate?: string;
  status?: ContractStatus;
}

model UpdateContractRequest {
  contractCode?: string;
  clientUnit?: string;
  projectName?: string;
  projectLocation?: string;
  constructionUnit?: string;
  inspectionSpecialtyCode?: string;
  buildingUnit?: string;
  supervisorUnit?: string;
  inspectionPerson?: string;
  inspectionPhone?: string;
  witnessUnit?: string;
  witness?: string;
  witnessPhone?: string;
  contactPerson?: string;
  contactPhone?: string;
  entrustedDate?: string;
  status?: ContractStatus;
}
