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

  // M01.F05.I03 SSO OAuth 2.0 授权码流 - 跳转端点（RFC 6749 §4.1.1）
  // response_type 必须为 "code"；client_id/redirect_uri/state 由前端生成（state
  // 验证在后端 cookie/session 中保留，防 CSRF）；client_secret 仅后端持（部署 env，
  // 不入 OpenAPI yaml）。lab 后端拿到 code 后 POST 到 saas /oauth/token 换 id_token，
  // 再解 user + 查 lab DB 算 permissions + 用 LAB_JWT_SECRET 签自家 JWT 返回。
  @get
  @route("/sso/authorize")
  op ssoAuthorize(
    @query response_type: OAuthResponseType,
    @query client_id: string,
    @query redirect_uri: string,
    @query state: string,
  ): SsoRedirect | ErrorResponse;

  // M01.F05.I03 SSO OAuth 2.0 授权码流 - token 交换（RFC 6749 §4.1.3）
  // body 含 grant_type/code/redirect_uri；client_secret 由后端从 env 注入 header
  // Authorization: Basic <base64(client_id:client_secret)>。返回 LoginResponse
  // （lab 自家 JWT，saas token 不出 lab 后端）。
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

// OAuth 2.0 授权码模式的 response_type 字面量（RFC 6749 §4.1.1）
// 当前仅实现 "code" 一种；隐式流/混合流不在范围内。
enum OAuthResponseType {
  code,
}

// OAuth 2.0 授权码模式的 grant_type 字面量（RFC 6749 §4.1.3）
// 同上，当前仅 authorization_code；password/client_credentials 不在范围。
enum OAuthGrantType {
  authorization_code,
}

model SsoCallbackRequest {
  grant_type: OAuthGrantType;
  code: string;
  redirect_uri: string;

  // RFC 6749 §4.1.4: client MUST send back the same state value received from
  // /auth/sso/authorize. lab signs the state with HS256 and stores it in an
  // HttpOnly Secure cookie; backend verifies body.state == cookie.state +
  // cookie signature before exchanging the code with saas /oauth/token.
  state: string;
}
