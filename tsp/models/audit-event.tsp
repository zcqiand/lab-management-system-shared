using TypeSpec.Http;

// AuditEvent — 审计事件（M01.F04/F05 认证 + 全局业务审计）。
namespace Lab.Management.Shared;

enum AuditAction {
  login,
  logout,
  create,
  update,
  delete,
  flow,
  export,
  other,
}

model AuditEvent {
  id: string;
  action: AuditAction;
  operator: string;
  target: string;
  targetId?: string;
  detail?: string;
  ip?: string;
  at: string;
  createdAt: string;
  updatedAt: string;
}
