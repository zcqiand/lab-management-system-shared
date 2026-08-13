using TypeSpec.Http;

// M01.F04 权限管理 + M01.F05 认证管理
// 实验室单租户：无 tenantId 路径参数。SSO 委托 saas 身份平台（本契约只声明端点形状）。
@route("/auth")
@tag("auth")
namespace Lab.Management.Shared.Auth {
  // M01.F05.I01 用户名+密码登录
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

  // M01.F05.I04 当前用户会话
  @get
  @route("/me")
  op getCurrentUser(): CurrentUser | ErrorResponse;

  // M01.F04.I04 动态权限集（身份平台下发）
  @get
  @route("/permissions")
  op getPermissions(): PermissionSet | ErrorResponse;

  // M01.F04.I04 动态菜单（身份平台下发）
  @get
  @route("/menus")
  op getMenus(): MenuNode[] | ErrorResponse;

  // M01.F05.I03 SSO 授权码流 — 跳转端点
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

model LoginResponse {
  token: string;
  refreshToken?: string;
  user: CurrentUser;
}

model RefreshTokenRequest {
  refreshToken: string;
}

model CurrentUser {
  id: string;
  username: string;
  displayName?: string;
  roleCode?: string;
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
