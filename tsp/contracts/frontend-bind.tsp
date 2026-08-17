using TypeSpec.Http;

// ============================================================
// Sprint 1 前端绑定契约 (Frontend Bind Contracts)
// ============================================================
// 用途:lab-react / lab-vue 双前端 Sprint 1 共享类型
// 范围:4-backend 运行时切换 + auth 4 态状态机 + 持久化 key 命名
// 约束:shared 仓只产 OpenAPI yml;运行时由消费方仓各自实现
//      (Vue: pinia store / React: Context)
// 出处:.state/decision-log.md §2 (Session 1 2026-08-17)
// ============================================================

namespace Lab.Management.Shared;

// ============================================================
// 2.1 BackendSwitch 契约
// ============================================================

@doc("4-backend 运行时切换配置。运行时由消费方仓各自实现(React Context / Vue pinia store)")
model BackendConfig {
  @doc("槽位标识,必须是 BackendId 之一")
  id: BackendId;

  @doc("显示名(MSW Mock / Next.js API / Spring Boot / ASP.NET Core)")
  label: string;

  @doc("baseUrl 的展示值,例如 'http://localhost:3000/api'")
  baseUrl: string;

  @doc("token 头:Bearer 走 Authorization,部分老后端用 X-Auth-Token")
  authHeader: AuthHeaderKind;

  @doc("SSO 回调路径(仅启用 SSO 的后端填写)")
  ssoCallbackPath?: string;

  @doc("能力矩阵")
  features: BackendFeatures;
}

@doc("4 个槽位;id 锁定,避免拼写漂移")
enum BackendId {
  msw,
  nextjs,
  springboot,
  aspnetcore,
}

enum AuthHeaderKind {
  Authorization,
  "X-Auth-Token",
}

@doc("后端能力矩阵")
model BackendFeatures {
  @doc("是否启用 SSO 跳转(msw=false / nextjs=true / springboot/aspnetcore 视实现)")
  sso: boolean;

  @doc("是否对接真实数据库(vs mock seed)")
  realDb: boolean;
}

@doc("运行时注册表:当前激活 + 可切列表。切换/订阅方法由消费方实现,TS 签名见 .state/decision-log.md §2.1")
model BackendRegistry {
  @doc("当前激活后端")
  active: BackendId;

  @doc("可切换列表(通常包含全部 4 个槽位)")
  available: BackendConfig[];
}

// ============================================================
// 2.2 AuthContext 契约
// ============================================================

@doc("auth 状态机 4 态。Vue: pinia store / React: Context;两侧实现可同构")
@discriminated
union AuthState {
  @doc("启动期:读 localStorage 之前")
  idle: {
    kind: "idle";
  },

  @doc("未登录态")
  anonymous: {
    kind: "anonymous";
  },

  @doc("有 token 但还没选租户;提示弹窗让用户选 tenantId")
  awaiting_tenant: {
    kind: "awaiting_tenant";
    user: CurrentUser;
    tenants: MyTenant[];
  },

  @doc("已登录;含 user + 当前 tenant + 过期时间")
  authenticated: {
    kind: "authenticated";
    user: CurrentUser;
    tenant: MyTenant;
    permissions: string[];
    @doc("unix ms")
    tokenExpiresAt: int64;
  },
}

@doc("AuthContext 数据契约。方法(login/logout/refresh/switchTenant/hasPermission/onChange)由消费方实现,TS 签名见 .state/decision-log.md §2.2")
model AuthContext {
  @doc("当前 auth 状态")
  state: AuthState;
}

// ============================================================
// 2.3 持久化 Key 命名(消费方实现 lock)
// ============================================================

@doc("前端持久化 key 命名约定;后端契约不感知,但前端实现必须遵守")
model TokenStorageKeys {
  @doc("Bearer token")
  accessToken: "lab.accessToken";

  @doc("refresh token(与 accessToken 分存,便于隔离 XSS 影响面)")
  refreshToken: "lab.refreshToken";

  @doc("当前选中租户 ID(authenticated 态缓存)")
  activeTenantId: "lab.activeTenantId";

  @doc("当前激活后端槽位(用于跨刷新记忆)")
  activeBackend: "lab.activeBackend";

  @doc("permissions 缓存(避免每次路由跳转都打 /auth/permissions)")
  permissionsCache: "lab.permissions";
}

// ============================================================
// _meta 锚点:声明一个 HTTP 路由返回所有 contract schema,
// 确保 2.1 / 2.2 / 2.3 全部 8 个 schema 进入 openapi.yaml
// (openapi3 emitter 的 omit-unreachable-types 会丢未关联的纯 model/union)。
// 后端不需要实现此路由——它是 TypeSpec 层面的 emit 锚点,
// 消费者只 codegen 类型,运行时通过现有 /auth/* 端点对接。
// ============================================================

@route("/_frontend-bind")
@tag("frontend-bind-meta")
namespace FrontendBindMeta {
  // Wrapper 让 BackendRegistry / AuthContext / TokenStorageKeys 全部可达
  model FrontendBindSnapshot {
    registry: BackendRegistry;
    authContext: AuthContext;
    tokenKeys: TokenStorageKeys;
  }

  @get
  @route("/snapshot")
  op getFrontendBindSnapshot(): FrontendBindSnapshot;
}