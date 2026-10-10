# REQ-2026-023 原生登录代理化 saas IdP(LAB_AUTH_DEV_PASSWORD 全家族退役)

| 项 | 值 |
|---|---|
| 提出人 | zcqiand |
| 提出日期 | 2026-10-11 |
| 优先级 | P1 |
| 状态 | **已评审**(方案 A 人裁,2026-10-11;实施中) |
| 关联 ADR | — |
| 上游 | REQ-2026-003 Q4-C(I06 端点人裁);REQ-2026-001(flutter 原生登录切片消费 I06);lab-flutter prod 首航验证暴露的凭据三态并存缺陷(2026-10-11) |

## 1. 需求描述

**用户原话**(2026-10-11,方案选择):

> 要 A(原生登录代理 saas 库——native-login 收到账密后转发 `saas /api/v1/auth/login`,saas 返 200 即签 lab JWT,LAB_AUTH_DEV_PASSWORD 全家族退役)

**背景**:

- lab 家族 5 后端的原生登录(M01.F05.I06)现行校验 = 本地 `ConfigUserDirectory.checkPassword`——mem-backed dev 目录,只认 `alice` + env `LAB_AUTH_DEV_PASSWORD`,不查任何数据库。2026-10-11 实测 VPS prod 三种状态并存:nextjs=32 位强随机串 / **aspnetcore=空值**(登录必 400)/ springboot+rails+fastapi=dev123456——凭据真源三态分裂,且与 saas 家族 prod 直用 alice/dev123456 的先例不一致。
- lab 仓内**已有**「账密代理 saas」先例:服务账号 `serviceLogin()`(POST saas `/api/v1/auth/login` 换 token 拉菜单快照)五仓齐备。用户账密走同一出站件即可,无需新建通道。
- 真正的身份 SSOT 是 saas 库:SSO 授权码流已在 saas 验证;原生登录平行维护一份 env 密码是身份双源,密码值漂移(本例)即登录故障。
- 用户目录本就是 `mem-backed, dev only;V014+ 换 DB` 的临时解(directory.ts:1)——代理化等价于把「换 DB」兑现为「换 saas 库」。

**范围**(以 5 后端行为共变为一体,无单一消费仓):

- 5 后端(naextjs/springboot/aspnetcore/rails/fastapi)login/native-login 处理链:删 `directory.checkPassword` 本地校验,改为用**请求体账密**调 saas `POST /api/v1/auth/login`(clientId 取 env `LAB_SAAS_CLIENT_ID`,缺失 fail-fast);响应映射复用各仓 sso/callback 现成富化链(saas user 无 displayName、availableTenants 无租户名 → /api/v1/me + /api/v1/admin/tenants,best-effort 降级 name=tenantId;roleCode=roleIds[0])。
- token 仍由各仓 LabJwtSigner 重签(lab 自家 JWT,I06 契约「LoginRequest→LoginResponse 同形,lab 自家 JWT + refreshToken」**形状不变**);refresh 签发维持 dev-placeholder 机制。
- 错误映射(五仓统一):saas 4xx → lab **401 `INVALID_CREDENTIALS`**(不透传 saas 的 UNAUTHORIZED 等内部码);saas 5xx/连接不可达/超时 → **502 `SAAS_UNAVAILABLE`**(ErrorResponse 形状)。
- `LAB_AUTH_DEV_PASSWORD`(flat 拼法)与 `Lab__Auth__DevPassword`(aspnetcore 分层拼法)全家族退役:6 处代码读点、4 仓 deploy 脚本、7 仓 ci.yml、env 样板、contract-test start-family、GH secrets(rails/fastapi)、VPS env 存量行、相关文档。

**非目标**:

- refresh 代理化(dev-placeholder 机制不动;saas refreshToken 透传/换发留后续需求)。
- 菜单快照仍走服务账号 serviceLogin(现有行为零改动)。
- msw mock(vendored 于 nextjs `vendor/msw`)不动——mock 模拟契约不模拟实现。
- 租户切换(M00.F02)、SSO 授权码流(I02/I03)零改动。

### 澄清记录

| 疑问 | 澄清结论 | 澄清人 | 日期 |
|---|---|---|---|
| Q1 平行 env 密码怎么统一?(A 代理化根治 / B 统一密码值 / C 先 B 后 A) | **裁定 A**(zcqiand 2026-10-11):原生登录校验委托 saas IdP,凭据真源归 saas 库,LAB_AUTH_DEV_PASSWORD 退役;B 的「统一 dev123456」会与 ADR-0019 禁兜底纪律和强密码实践冲突,不取。 | zcqiand | 2026-10-11 |
| Q2 msw mock 要不要跟着代理? | 不动。msw 模拟契约(响应形状)不模拟实现(校验路径);vendored login mock 本地校验继续有效,因其响应形状与代理后一致。 | zcqiand | 2026-10-11 |
| Q3 token 重签 vs saas token 透传?(nextjs sso/callback 是透传先例) | 重签。I06 契约明文「lab 自家 JWT」;编译型 3 后端 sso 也重签(家族差异点维持);透传会引入「lab 契约 token 被 saas key 验签」的跨域耦合。 | zcqiand | 2026-10-11 |

## 2. 验收标准

| 编号 | 场景(给定) | 操作(当) | 预期(则) |
|---|---|---|---|
| AC-1 | saas 可达,账密存在于 saas 库(alice/dev123456) | POST /api/auth/native-login | 200 LoginResponse:user.username/email 来自 saas user;tenants[] 四字段(tenantId/code/name/roleIds)齐全;富化 200→真名,失败→降级 name=tenantId 整体仍 200;token 为 lab 自家 JWT |
| AC-2 | 同上 | 同上 | 出站 LoginRequest.clientId==`LAB_SAAS_CLIENT_ID`,username/password 原值透传 |
| AC-3 | saas 对该账密返 401 | POST native-login | lab 401 `INVALID_CREDENTIALS`(saas 内部错误码不透传) |
| AC-4 | saas 5xx / 连接拒绝 / 超时 | POST native-login | 502 `SAAS_UNAVAILABLE`,ErrorResponse 形状 |
| AC-5 | 全家族 grep `LAB_AUTH_DEV_PASSWORD\|Lab__Auth__DevPassword\|dev-password\|DevPassword` | (退役后) | 零命中(CHANGELOG/历史 REQ 除外) |
| AC-6 | contract-test live 五方 | 跑 auth.test.ts login+native-login | 全绿(状态族+normalize 形状不回归;live 前提=saas 可达) |
| AC-7 | lab-flutter(响应形状不变) | 原生登录 | 零改动可用;prod 浏览器原生登录人工验收通过 |

## 3. 任务拆解

| 任务 ID | 任务描述 | 类型 | 仓 | 状态 |
|---|---|---|---|---|
| T-0 | shared tree-change 提案(approved=false)+ 人批 + 写树(I06 描述代理语义,状态=开发中)+ 本 REQ 落库 + contract-test auth.test.ts 注释(硬规则 §2 同步论证,同 commit) | 契约/治理 | shared + contract-test | 待开工 |
| T-1 | nextjs 代理化:route.ts+saas.ts 参数化出站+映射;directory 收敛;factory REQUIRED_KEYS 调整;红先测试 | 实现 | nextjs | 待 T-0 |
| T-2 | springboot 同构(AuthService+SaasAuthClient 参数化;ConfigUserDirectory/@Value 收敛) | 实现 | springboot | 待 T-1 |
| T-3 | aspnetcore 同构(AuthService+ISaasAuthClient;ConfigBuilder RequireDevPassword 删) | 实现 | aspnetcore | 待 T-2 |
| T-4 | rails 同构(auth_service+SaasAuthClient;user_directory 收敛) | 实现 | rails | 待 T-3 |
| T-5 | fastapi 同构(auth_impl+SaasClient;directory/config 收敛) | 实现 | fastapi | 待 T-4 |
| T-6 | 退役面清理:4 deploy 脚本三段 + 7 ci.yml + start-family.sh + env 样板 + 文档(3×ARCHITECTURE/REQ-2026-009/env.md) | 清理 | 全家族 | 待 T-5 |
| T-7 | 顺序 tag 部署链 + VPS env 存量行清理 + prod 探针(native-login 200/401/502 三态)+ flutter prod 人工验收 → 记录本 REQ | 部署 | 全家族 | 待 T-6 |
| T-8 | GH secrets 清理(rails/fastapi)+ 收尾(记忆/handoff) | 收尾 | 全家族 | 待 T-7 |

## 4. 功能影响

**tree-change**:M01.F05.I06(原生登录)action=变更:行描述追加「校验委托 saas IdP 代理(REQ-2026-023),lab JWT 重签与响应契约形状不变;LAB_AUTH_DEV_PASSWORD 退役」;状态 规划→开发中(树状态枚举无「已评审」,随实施推进,验收后 GA)。提案 sync_files 含本 REQ。

**contract-test 同步论证**(suite 硬规则 §2「端点增/改/删必须同 commit 同步 contract-test」):本变更是 I06 的**实现语义变更**——LoginResponse 成员集(token/refreshToken/user/tenants)、MyTenant 四字段、ErrorResponse 形状、错误状态族(4xx/5xx)全部不变;变更的是校验委托方(本地目录→saas IdP)。断言与 normalize(token/refreshToken volatile 剔除)无结构变更义务;满足方式 = `tests/auth.test.ts` describe 头注释(实现语义+live 前提:saas 可达+LAB_SAAS_CLIENT_ID 注入)+ 本节交叉引用。若某仓映射漂移致 normalize 破裂,**不允许改 normalize 迁就,回改该仓映射**。

## 6. 风险

| 编号 | 风险 | 缓解 |
|---|---|---|
| R1 | **单点化**:密码校验变出站依赖 saas,saas 不可达=lab 全家族(native+sso)登录 502;native 是 flutter 唯一登录通道 | 统一 502 SAAS_UNAVAILABLE+明确文案;低峰窗口部署前验 saas 健康;缓存/降级策略列非目标留档 |
| R2 | 旧 tag rerun 重部署旧码(deploy 链指纹):旧码读 LAB_AUTH_DEV_PASSWORD 而 VPS env 已清 → 启动 fail-fast | 一律新 tag;部署后冒烟;废 tag 留红不删 |
| R3 | aspnetcore 分层键:`Lab__Auth__DevPassword` C# 读点删净与 VPS env 残留须同批 | ConfigBuilder/Program/appsettings 与 deploy 脚本同 PR;部署前 VPS sed 删行 |
| R4 | contract-test normalize 回归:五仓映射各自手写(displayName 缺省/租户名降级/roleCode 取值),任一仓漂移即破裂 | 红测试锁形状+降级路径单测+五方 live 比对;禁改 normalize 迁就 |
| R5 | clientId 缺失:静默误报 401 | 启动 fail-fast(requireEnv/@Value 无默认/_require_env/ENV.fetch 同纪律) |
| R6 | fastapi 双入口透传:auth_native_login 转发 auth_login,须确认请求体账密透传、不残留 dev 密码路径 | 红测试覆盖 native 与 login 同响应;grep 残留读点 |

## 7. 实施记录

- 2026-10-11 REQ 落库;tree-change 提案待人批。
