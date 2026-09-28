using TypeSpec.Http;

// M00 租户管理 + M01.F04 权限管理 + M01.F05 认证管理
// 多租户：一个用户关联多个租户，登录后选一个进去。租户真相源在 saas 身份平台，
// lab 不建 tenants 表，运行时通过 /auth/me 拿用户关联的租户列表。
@route("/auth")
@tag("auth")
namespace Lab.Management.Shared.Auth {
  // M01.F05.I01 用户名+密码登录 — 2026-09-17 标记 已废弃；op 暂留待消费仓同步后删（BASE 端点须随 9 仓迁移一并下线）
  // follow-up: lab-springboot/lab-aspnetcore ServiceLogin(labConfig.sso().serviceUser/...) + lab-live_smoke /auth/login 探针 + contract-test 13 注解 全部迁移到 saas service-account 或 lab-internal endpoint 后，删 op + LoginRequest/Response model
  // 2026-09-28 修订：LoginRequest 由 M01.F05.I06（原生登录）沿用——I01 删除时 LoginRequest 不随删，LoginResponse 因 refresh/switch-tenant/sso-callback 继续保留
  @post
  @route("/login")
  op login(@body body: LoginRequest): LoginResponse | ErrorResponse;

  // M01.F05.I06 原生登录（非浏览器客户端：iOS/Android 原生表单）— REQ-2026-003 Q4-C（2026-09-28 人裁 A+B+C）
  // 为原生客户端新开的密码通道，**非恢复 web 密码端点**（I01 仍为已废弃，web 端走 SSO I02/I03）。
  // 请求/响应与 login 同形（LoginRequest → LoginResponse），lab 后端按 service-account
  // 口径校验后签发 lab 自家 JWT（含 refreshToken）。浏览器客户端禁止调用（后端按
  // Origin/Client 约束，契约层不做 UA 判断）。
  @post
  @route("/native-login")
  op nativeLogin(@body body: LoginRequest): LoginResponse | ErrorResponse;

  // M01.F05.I04 token 刷新
  @post
  @route("/refresh")
  op refresh(@body body: RefreshTokenRequest): LoginResponse | ErrorResponse;

  // M01.F05.I05 登出
  @post
  @route("/logout")
  op logout(@body body: { token: string }): void | ErrorResponse;

  // M00.F01.I01 当前用户会话（含关联租户列表）
  @get
  @route("/me")
  op getCurrentUser(): CurrentUserSession | ErrorResponse;

  // M00.F02.I01 登录后选择租户（换发携带该 tenant_id claim 的 token）
  @post
  @route("/switch-tenant")
  op switchTenant(@body body: SwitchTenantRequest): LoginResponse | ErrorResponse;

  // M01.F04.I02 动态权限集（身份平台下发，按当前租户）
  @get
  @route("/permissions")
  op getPermissions(): PermissionSet | ErrorResponse;

  // M01.F04.I01 动态菜单（身份平台下发，按当前租户）
  // 注：F04.I04（lab 侧边栏容器）走 type=标签页不参与反向候选
  @get
  @route("/menus")
  op getMenus(): MenuNode[] | ErrorResponse;

  // M01.F05.I02 SSO OAuth 2.0 授权码流 - 跳转端点（RFC 6749 §4.1.1）
  // response_type 必须为 "code"；client_id/redirect_uri/state 由前端生成（state
  // 验证在后端 cookie/session 中保留，防 CSRF）；client_secret 仅后端持（部署 env，
  // 不入 OpenAPI yaml）。lab 后端拿到 code 后 POST 到 saas /oauth/token 换 id_token，
  // 再解 user + 查 lab DB 算 permissions + 用 LAB_JWT_SECRET 签自家 JWT 返回。
  // redirect_uri 白名单（REQ-2026-003 Q4-B，2026-09-28 人裁）：除 https 域名外，
  // 原生客户端允许自定义 scheme（如 labmanagement://callback）；白名单校验在
  // lab 后端实现，配置随部署 env（不入契约）。
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
  // state 验证双轨（REQ-2026-003 Q4-A，2026-09-28 人裁）：cookie 之外，后端同时
  // 接受 body.state 对上 ssoAuthorize 签发时留存的服务端记录（一次性消费、
  // 短时效）——为原生/非浏览器客户端提供对账路径（dev http 下 Secure cookie
  // 不落盘，家族「state cookie 按 host 分档」先例）。两轨任一通过即放行。
  state: string;
}
