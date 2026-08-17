# Sprint 1 契约决策日志

> 起草日：2026-08-17
> 起草人：suite 调度
> 状态：**草案**（待 Session 1 在 shared/ 仓落实）
> 范围：lab-management-system 双前端（lab-react / lab-vue）Sprint 1 的**前端层绑定契约**
> 阅读对象：下一 session 进 shared/ 仓跑 Phase 3 的 agent

---

## 0. 这个文件是干嘛的

Sprint 1 的两个前端 session（lab-react、lab-vue）要在 5-7 天内写出 8 个共享文件并保证字段对齐。错一字段双仓返工。

把**前后端边界上的类型契约**（不是 HTTP 端点，端点已在 `tsp/routes/auth.tsp`）、**运行时 4-backend 切换的字段**、**auth 状态机的 4 个状态**先在 shared/ 仓沉淀下来，让 Session 1 直接 `npm run build` 产出 OpenAPI yml，两端 session 拿到 consume 即可。

**为什么放 .state/decision-log.md 而不是 docs/adr/**：本仓 `docs/adr/` 仍空（2026-08-17 实测），且本文件是「下一阶段工作输入」而非「why-we-did-this 决策史记」，放 `.state/` 与 session.json 同级，便于 Session 1 冷启动时一站读全。

---

## 1. 边界与原则

| # | 决策 | 理由 |
|---|------|------|
| D1 | HTTP 端点契约已在 `tsp/routes/auth.tsp` 落地（含 `login`/`refresh`/`logout`/`me`/`switch-tenant`/`permissions`/`menus`/`sso/authorize`/`sso/callback`），**Sprint 1 不动** | `Last gate` 绿；动了会触发 6 仓 codegen 不同步 |
| D2 | 前端层绑定契约（`BackendSwitch` / `AuthContext`）**必须在 shared/ 仓产 TypeScript 类型**，但**不放 runtime 代码**（shared/CLAUDE.md §2 禁止业务代码 + 禁止 npm runtime 依赖） | shared 是契约仓；runtime 由消费方仓实现 |
| D3 | TypeScript 类型落地路径：`tsp/contracts/frontend-bind.tsp` → `tsp compile` 产出到 `generated/openapi/openapi.yaml` 的 `components.schemas` → 消费方仓各自的 codegen 把 `BackendSwitch` / `AuthContext` 抽到 `src/api/contracts.ts` | 保持 SSOT 单一来源；不破坏 `tsp compile` 的现有发射结构 |
| D4 | 4-backend 列举：`msw` / `nextjs` / `springboot` / `aspnetcore` | 与 family 7 仓（react/vue/nextjs/springboot/aspnetcore/msw）一一对应；msw 是 mock 但走同等 baseUrl 形态 |
| D5 | `AuthState` 是 4 态有限状态机：**idle → anonymous → awaiting_tenant → authenticated** | 业内做 SSO 多租户 + token 换发的标准模式；Vue/React 两侧实现可同构 |
| D6 | `msw` 后端 SSO 字段关闭（`features.sso = false`），仅示意；`nextjs` 后端开启 | msw 走 mock 不接真实身份平台；nextjs 是 BFF 默认开启 |
| D7 | Token 持久化 key 前缀统一为 `lab.<scope>`，由消费方仓实现（localStorage vs sessionStorage 留给前端） | shared 不指定存储介质；只锁名字 |

---

## 2. 字段草稿（TypeSpec，以 .tsp 文本形态）

> 完整 TypeSpec 文件路径预计：`tsp/contracts/frontend-bind.tsp`
> 消费方 codegen 后在 `src/api/contracts.ts` 见到下述同名类型

### 2.1 BackendSwitch 契约

```typespec
@doc("4-backend 运行时切换配置。Session 1 在 shared/ 仓的 status 类型；运行时由消费方仓各自实现。")
model BackendConfig {
  @doc("槽位标识，必须是 BackendId 之一")
  id: BackendId;

  @doc("显示名（'MSW Mock' / 'Next.js API' / 'Spring Boot' / 'ASP.NET Core'）")
  label: string;

  @doc("baseUrl 的展示值，例如 'http://localhost:3000/api' 或 'https://api.example.com/api'")
  baseUrl: string;

  @doc("token 头：Bearer 走 Authorization，部分老后端用 X-Auth-Token")
  authHeader: AuthHeaderKind;

  @doc("SSO 回调路径（仅启用 SSO 的后端填写）")
  ssoCallbackPath?: string;

  @doc("能力矩阵")
  features: BackendFeatures;
}

@doc("4 个槽位；id 锁定，避免拼写漂移")
enum BackendId {
  msw,
  nextjs,
  springboot,
  aspnetcore,
}

enum AuthHeaderKind {
  Authorization,
  X-Auth-Token,
}

model BackendFeatures {
  @doc("是否启用 SSO 跳转")
  sso: boolean;

  @doc("是否对接真实数据库（vs mock seed）")
  realDb: boolean;
}

@doc("运行时注册表：当前激活 + 可切列表 + 变更订阅")
model BackendRegistry {
  active: BackendId;
  available: BackendConfig[];

  @doc("切换激活后端；持久化由消费方负责")
  switch(id: BackendId): void;

  @doc("订阅切换事件，返回 unsub 函数")
  onSwitch(handler: SwitchHandler): UnsubscribeFn;
}

// 回调签名（TypeSpec 用 string 表示，TypeScript 侧签名是 (newId: BackendId) => void）
op SwitchHandler(newId: BackendId): void;
op UnsubscribeFn(): void;
```

### 2.2 AuthContext 契约

```typespec
@doc("auth 状态机 4 态。消费方两侧都基于此实现 React Context / Vue pinia store。")
@discriminated("kind")
model AuthState {
  @doc("启动期：读 localStorage 之前")
  idle: {},

  @doc("未登录态")
  anonymous: {},

  @doc("有 token 但还没选租户；提示弹窗让用户选 tenantId")
  awaiting_tenant: { user: CurrentUser; tenants: MyTenant[]; },

  @doc("已登录；含 user + 当前 tenant + 过期时间")
  authenticated: {
    user: CurrentUser;
    tenant: MyTenant;
    permissions: string[];
    tokenExpiresAt: int64;  // unix ms
  },
}

@doc("AuthContext 行为契约。Vue/React 两侧实现可同构。")
model AuthContext {
  state: AuthState;

  @doc("用户名+密码登录")
  login(req: LoginRequest): LoginResponse | ErrorResponse;

  @doc("登出：清 token + 退到 anonymous")
  logout(): void | ErrorResponse;

  @doc("静默刷新：基于 refreshToken；401 时退到 anonymous")
  refresh(): LoginResponse | ErrorResponse;

  @doc("登录后选租户（仅在 awaiting_tenant 态可调）")
  switchTenant(req: SwitchTenantRequest): LoginResponse | ErrorResponse;

  @doc("RBAC 单点判断（来自 /auth/permissions 缓存）")
  hasPermission(perm: string): boolean;

  @doc("订阅状态变更；返回 unsub 函数")
  onChange(handler: AuthChangeHandler): UnsubscribeFn;
}

op AuthChangeHandler(state: AuthState): void;
```

### 2.3 持久化 Key 命名（消费方实现 lock）

```typespec
@doc("前端持久化 key 命名约定；后端契约不感知，但前端实现必须遵守")
model TokenStorageKeys {
  @doc("Bearer token")
  accessToken: "lab.accessToken";

  @doc("refresh token（与 accessToken 分存，便于隔离 XSS 影响面）")
  refreshToken: "lab.refreshToken";

  @doc("当前选中租户 ID（authenticated 态缓存）")
  activeTenantId: "lab.activeTenantId";

  @doc("当前激活后端槽位（用于跨刷新记忆）")
  activeBackend: "lab.activeBackend";

  @doc("permissions 缓存（避免每次路由跳转都打 /auth/permissions）")
  permissionsCache: "lab.permissions";
}
```

---

## 3. 落地任务清单（给 Session 1 直接读）

> Session 1 = 新 session 进 lab-management-system-shared/ 仓跑 Phase 3。
> 预计工时 2-3 天。

- [ ] **T1** 创建 `tsp/contracts/frontend-bind.tsp` 写本文件 §2 全部 TypeSpec
- [ ] **T2** `main.tsp` 加 `import "./tsp/contracts/frontend-bind.tsp"`（注意：models 模块下，加在 models 那一组附近）
- [ ] **T3** `npm run build`（只跑 emit:openapi —— per CLAUDE.md §4 禁止改）
- [ ] **T4** L1 / L3 / L4 gate 跑绿（`.state/trace.json` 已有运行机制）
- [ ] **T5** 更新 `generated/openapi/openapi.yaml` 的 `components.schemas` 校验：
  - `BackendConfig` / `BackendId` / `BackendRegistry` / `BackendFeatures` / `AuthHeaderKind` / `AuthState` / `AuthContext` / `TokenStorageKeys` 9 个类型齐全
- [ ] **T6** 提交 commit（建议前缀 `feat(shared): Sprint 1 前端绑定契约 BackendSwitch + AuthContext`），推 origin
- [ ] **T7** 更新 `output/lab-management-system-shared/.state/session.json`：
  - `current_task` = "Phase 3 Sprint 1 前端绑定契约落地（BackendSwitch + AuthContext）"
  - `next` 写明消费方接契约定指南
- [ ] **T8** 通知父亲仓指针升级（suite 端 `git add output/lab-management-system-shared` + commit `chore(suite): 推进 shared 指针 Sprint 1 契约`）

---

## 4. 风险与避险

| 风险 | 影响 | 规避 |
|------|------|------|
| shared Phase 2 msw-deletion RUNNING，与 Sprint 1 契约同时改 `tsp/` 容易冲突 | 指针打架 / codegen 漏 1 仓 | Phase 2 收尾后再开 T1；或者按 Phase 2 → Phase 3 顺序串行 |
| `AuthState` 在 awaiting_tenant 状态忘带 tenants 列表 | Vue pinia store 拿不到租户切换候选 | TypeSpec 字段已 lock；codegen 漏字段会被 L3 类型检查拦 |
| `TokenStorageKeys` 名字写错（`lab.token` vs `lab.accessToken`） | 双仓字符串不一致 | TypeSpec 抽到 `model` 后双方 codegen 拿到同一字面量类型 |
| 4-backend 切换没做持久化 | 刷新页面后丢失 | `activeBackend` 走 `TokenStorageKeys` 锁的 key |
| `permissionsCache` 缓存过期 | 路由守卫错判 | 留给消费方实现：TTL 5 分钟 + 主动失效点（switchTenant / logout） |
| Vue 仓按习惯走 `provide/inject` 实现 AuthContext | 双仓实现路径不一致 | Session 1 在本文件 §2.2 model 上注明 `// Vue: pinia store / React: Context`，session 启动时一眼看到 |

---

## 5. 不在 Sprint 1 范围（明确排除）

- 真实 SSO 流（`/auth/sso/authorize` / `/auth/sso/callback`）—— 仅预留契约字段，msw 后端 skills.sso=false，登录走用户名密码
- 表单校验规则强弱（密码强度、登录失败次数限流）—— 留给 Sprint 2
- Refresh token 轮转 / 静默刷新定时器具体实现 —— 留给消费方 session
- 路由守卫的具体路由表（哪条路由要哪个 permission）—— 留给 AppShell session 加载
- 仪表盘空壳页面内容 —— 仅 Sprint 2 加业务

---

## 6. 验收判据

Session 1 完成后必须全部满足：

1. `python scripts/gate.py -p lab-management-system-shared` exit 0
2. `generated/openapi/openapi.yaml` 含 9 个新 schema，路径 `components.schemas.BackendConfig` 等可被 `!ref` 引用
3. `tsp/contracts/frontend-bind.tsp` 已 commit 且 push origin
4. 父亲仓指针已更新（suite 端 commit `chore(suite): 推进 shared 指针 Sprint 1 契约`）
5. `.state/decision-log.md` 顶部状态变为 `落地完成`（本文件内联改）
6. Session 1 结束时调 `python scripts/gate.py -p lab-management-system-shared` 实测，不靠记忆

---

## 7. 给 Session 1 冷启动的 tl;dr

```
任务：在 shared/ 仓跑 Phase 3，把本文件 §2 的 TypeSpec 字段落地到 tsp/contracts/frontend-bind.tsp。
前置：共享 Phase 2 msw-deletion RUNNING 状态必须先收口，否则拒绝启动。
约束：shared/CLAUDE.md §2 全部（禁止业务代码 / 禁止 runtime npm / 禁止手写 OpenAPI yaml）。
交付：9 个 schema 入 yaml + gate 绿 + 父亲仓指针升级。
验收：见 §6 六条。
工时预算：2-3 天。
```

---

## 修订记录

| 日期 | 修订人 | 内容 |
|------|--------|------|
| 2026-08-17 | suite 调度 | 草案初版 |
