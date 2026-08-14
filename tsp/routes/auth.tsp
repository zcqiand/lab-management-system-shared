using TypeSpec.Http;

// M00 租户管理 + M01.F04 权限管理 + M01.F05 认证管理
// 多租户：一个用户关联多个租户，登录后选一个进去。租户真相源在 saas 身份平台，
// lab 不建 tenants 表，运行时通过 /auth/me 拿用户关联的租户列表。
@route("/auth")
@tag("auth")
namespace Lab.Management.Shared.Auth {
  // M01.F05.I01 用户名+密码登录（返回 token + 用户 + 关联租户列表）
  @post
  @route("/login")
  op login(@body body: LoginRequest): LoginResponse | ErrorResponse;

  // M01.F05.I02 token 刷新
  @post
  @route("/refresh")
  op refresh(@body body: RefreshTokenRequest): LoginResponse | ErrorResponse;

  // M01.F05.I05 登出
  @post
  @route("/logout")
  op logout(@body body: { token: string }): void | ErrorResponse;

  // M00.F01 当前用户会话（含关联租户列表）
  @get
  @route("/me")
  op getCurrentUser(): CurrentUserSession | ErrorResponse;

  // M00.F02 登录后选择租户（换发携带该 tenant_id claim 的 token）
  @post
  @route("/switch-tenant")
  op switchTenant(@body body: SwitchTenantRequest): LoginResponse | ErrorResponse;

  // M01.F04.I04 动态权限集（身份平台下发，按当前租户）
  @get
  @route("/permissions")
  op getPermissions(): PermissionSet | ErrorResponse;

  // M01.F04.I04 动态菜单（身份平台下发，按当前租户）
  @get
  @route("/menus")
  op getMenus(): MenuNode[] | ErrorResponse;

  // M01.F05.I03 SSO 授权码流 - 跳转端点
  @get
  @route("/sso/authorize")
  op ssoAuthorize(@query redirect: string): SsoRedirect | ErrorResponse;

  // M01.F05.I03 SSO 回调换 token
  @post
  @route("/sso/callback")
  op ssoCallback(@body body: SsoCallbackRequest): LoginResponse | ErrorResponse;
}

model LoginRequest {
  username: string;
  password: string;
}

// 登录响应：token + 用户 + 该用户关联的租户列表（前端弹窗选一个）
model LoginResponse {
  token: string;
  refreshToken?: string;
  user: CurrentUser;
  tenants: MyTenant[];
}

model RefreshTokenRequest {
  refreshToken: string;
}

// 选租户请求：登录后用户挑一个 tenantId，后端换发带该 tenant_id claim 的 token
model SwitchTenantRequest {
  tenantId: string;
}

model CurrentUser {
  id: string;
  username: string;
  displayName?: string;
  roleCode?: string;
}

// 当前会话：用户 + 关联租户 + 当前选中租户
model CurrentUserSession {
  user: CurrentUser;
  tenants: MyTenant[];
  currentTenantId?: string;
}

// 从 saas 身份平台下发的租户视图（lab 不拥有 tenants 表）
model MyTenant {
  tenantId: string;
  code: string;
  name: string;
  roleIds: string[];
}

model PermissionSet {
  permissions: string[];
}

model MenuNode {
  id: string;
  label: string;
  path?: string;
  icon?: string;
  children?: MenuNode[];
}

model SsoRedirect {
  authorizeUrl: string;
  state: string;
}

model SsoCallbackRequest {
  code: string;
  state: string;
}
