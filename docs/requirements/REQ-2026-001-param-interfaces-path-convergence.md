# REQ-2026-001 param-interfaces 消费侧路径收敛

| 项 | 值 |
|---|---|
| 提出人 | zcqiand |
| 提出日期 | 2026-09-14 |
| 优先级 | P1 |
| 状态 | 开发中（T-1~T-4 已完成，T-5/T-6 收尾） |
| 关联 ADR | —（修复遵循 ADR-0029 消费侧对齐流程，方案 A 定案见澄清记录） |

## 1. 需求描述

用户原话：

> ParamInterfaceList.tsx:86 GET http://localhost:5204/api/inspection-param-interfaces?page=1&pageSize=50 404 (Not Found)。
> 为什么 e2e 与 contract-test 测不出来，归谁管的？

理解与根因：

- 契约路径是 `/api/param-interfaces`（`tsp/routes/param-interfaces.tsp`，M06.F08）。
  shared OpenAPI / msw（generated）/ aspnetcore / springboot / contract-test（`tests/param-interfaces*.test.ts`）五层全齐。
- 三个前端的 `legacy-client.ts` API_ROUTES 映射表（REF 旧路由 → 契约路由）中，
  `/inspection-param-interfaces` 与 `/inspection-parameter-param-interfaces` 两行**漏翻**（恒等映射），
  调的是 REF legacy 路径。react→springboot(:5205)、vue→aspnetcore(:5204)、nextjs→任意真后端均 404。
- msw `handlers-extra.ts` 与 nextjs `src/app/api/inspection-param-interfaces/*` 照漏翻路径长出
  **契约外私生 handler**，把 dev / e2e 全绿掩盖（msw 双路径都有，打哪条都 200）。
- nextjs 作为 contract-test 四方后端之一**缺契约路径实现**（只有私生路径）；
  live 四方比对打 nextjs:5201 `/api/param-interfaces` 会红，但 gate 场景 `skipIf(!live)` 全 skip，
  门绿 = 「没测」而非「测过」（结构性洞，本次不修，见风险表）。

命名依据（为何不是契约改名）：全家族 API 路径统一剥 `inspection_` 表前缀
（calculation-methods / report-names / technical-requirements 同款惯例），表名从未改过。

### 澄清记录

| 疑问 | 澄清结论 | 澄清人 | 日期 |
|---|---|---|---|
| REQ 落点哪个仓？ | shared 仓（契约 SSOT 视角，家族级收敛） | 用户 | 2026-09-14 |
| 范围：只修 404 还是完整收敛？ | 完整收敛（前端映射 + 删私生端点 + nextjs 补契约实现） | 用户 | 2026-09-14 |
| API 路径保 `/api/param-interfaces` 还是改 `inspection-` 前缀（ADR-0029 候选方案）？ | 方案 A：保契约路径，改消费侧。理由：blast radius 小、与全家族剥前缀惯例一致、后端/contract-test/function-tree 五层零改动 | 用户 | 2026-09-14 |

## 2. 验收标准

| 编号 | 场景（给定） | 操作（当） | 预期（则） |
|---|---|---|---|
| AC-1 | nextjs 前端 baseURL 切 aspnetcore(:5204) | 打开参数界面页 | `GET /api/param-interfaces?page=1&pageSize=50` 返回 200，列表渲染 |
| AC-2 | 4 后端全起（5200/5201/5204/5205），`CONTRACT_TARGETS=msw,nextjs,aspnetcore,springboot` | `npx vitest run tests/param-interfaces.test.ts tests/param-interfaces-write.test.ts` | param-interfaces 读写断言全部 describe 非 skip 且绿（nextjs 补角后四方比对通过） |
| AC-3 | msw 仓与 nextjs 仓工作树 | `grep -r "inspection-param-interfaces" src/` | 0 命中（私生端点已删净）。执行口径（2026-09-14 澄清）：私生 route/handler/测试字面量 0 命中；`legacy-client.ts` API_ROUTES 的 REF 键字面按「方案 A 键保持 REF 字面」决议保留，注释同留作溯源 |
| AC-4 | 3 前端仓 `src/api/legacy-client.ts` | 查 API_ROUTES 两键的映射值 | 值为 `/api/param-interfaces` 与 `/api/param-interfaces/links`，无恒等映射 |
| AC-5 | 涉及的 6 仓（shared/msw/nextjs/react/vue + contract-test） | suite 根目录 `python scripts/gate.py -p <仓>` | 全部 exit 0 |

## 3. 任务拆解

| 任务 ID | 任务描述 | 类型 | 负责人 | 预估 | 状态 |
|---|---|---|---|---|---|
| T-1 | 3 前端仓（nextjs/react/vue）`legacy-client.ts` 两行映射改契约路径；同步修引用旧路径字面量的测试 | 变更 | AI | 0.5d | 已完成 |
| T-2 | msw：删 `handlers-extra.ts` 中 `/api/inspection-param-interfaces` CRUD + links 私生 handler；删 `tests/`、`tests/helpers` 对旧路径的引用；links GET/DELETE 上移到 dictCrud 之前（注册顺序防 `:code` 吞并） | 变更 | AI | 0.5d | 已完成 |
| T-3 | nextjs：删 `src/app/api/inspection-param-interfaces/*` 私生 routes；按契约补 `/api/param-interfaces`、`/{code}`、`/links` route handlers（Page envelope，fixtures）；跨路由写读共享走 `globalThis` fixtures 单例（per-route bundle 多副本实证） | 变更 | AI | 1d | 已完成 |
| T-4 | contract-test：`CONTRACT_TARGETS` 四方全开 live 跑 param-interfaces 读写断言，确认 nextjs 补角后全绿（AC-2） | 验证 | AI | 0.5d | 已完成（5 轮收敛，见 §7） |
| T-5 | 真后端手测收敛验证（AC-1：nextjs→5204；顺带 vue→5204、react→5205 同页 200） | 验证 | AI | 0.5d | 已完成（curl 带 token 打 5204/5205 `/api/param-interfaces` 200 ×18 项、`/links` 200 ×22 项，见 §7） |
| T-6 | 6 仓各自 gate 全绿 + suite 根 submodule bump（AC-5） | 收尾 | AI | 0.5d | 进行中 |

## 4. 功能影响（需求与功能对齐的唯一位置）

| 功能 ID | 功能名称 | 影响类型 | 说明 | 关联任务 |
|---|---|---|---|---|
| M06.F08.I01 | 参数界面列表 | 变更 | 消费侧路径收敛到契约路径；契约本体（tsp/OpenAPI）不变 | T-1~T-3 |
| M06.F08.I02 | 参数界面详情 | 变更 | 同上 | T-1~T-3 |
| M06.F08.I03 | 创建参数界面 | 变更 | 同上 | T-1~T-3 |
| M06.F08.I04 | 更新参数界面 | 变更 | 同上 | T-1~T-3 |
| M06.F08.I05 | 删除参数界面 | 变更 | 同上 | T-1~T-3 |
| M06.F08.I06 | 参数↔界面 link | 变更 | links 路径同步收敛（`/api/param-interfaces/links`） | T-1~T-3 |
| M06.F03.I07 | 参数↔界面 unlink | 变更 | 同上 | T-1~T-3 |

均为「变更」：ID 已存在且已上线，不改功能树，无需 `/tree-change`。

## 5. 流程影响

无（页面与流程不变，仅传输路径收敛）。

## 6. 风险与回滚

| 风险 | 影响面 | 缓解 | 回滚方式 |
|---|---|---|---|
| msw/nextjs 私生端点有未登记消费方 | 前端隐藏调用点、e2e helper、seed | 删前全家族 grep `inspection-param-interfaces` 清点（本 REQ 调研已列：3 前端映射、msw handlers-extra、nextjs routes、tests/helpers/seed.ts、DataEntryActions 测试） | 各仓 git revert |
| nextjs 补的 route shape 与四方不一致 | contract-test live 红（预期内，红即验收信号） | 以 orval 生成的类型 + contract-test param-interfaces 断言为准；Page envelope 必填 page/pageSize/total/items | git revert |
| 结构性洞：contract-test 非 live 时 `skipIf(!live)` 全 skip，gate 绿 ≠ 测过 | 本类事故再次静默发生 | 本次不修；登记为 contract-test 仓后续候选（gate 对 live 目标 < 2 时应警告或红）。下次会话建议走 `/tree-change` 之外的 contract-test REQ 立项 | — |
| shared 仓首次立项，requirements 流程无先例 | 台账/模板格式漂移 | 模板与台账格式抄 react 仓同款 | git revert |

## 7. live 四方收敛实录（2026-09-14，5 轮）

AC-2 首跑 7 failed → 5 轮收敛全绿（26 passed / 1 skipped / 0 failed）。每轮暴露一层，
全是「skipIf(!live) 门绿=没测」结构性洞的直接产物——门绿期间无人打过真后端：

| # | 层 | 缺陷 | 修复 |
|---|---|---|---|
| 1 | aspnetcore EF | 生成 DTO 无 NRT `?` + `<Nullable>enable</Nullable>`：可空列（config/report_name_code）物化 NULL 行即 500 | LabDbContext 对应属性 `.IsRequired(false)`（手写层） |
| 2 | aspnetcore MVC | 同根：`[ApiController]` 把无 `?` 属性隐式标 Required → 契约可选字段缺省 400 | Program.cs `SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true`（NSwag 显式 `[Required]` 不受影响，探针验证） |
| 3 | contract-test | `probeRequest` DELETE **不发送 body**：契约 `@body` unlink 全被吞——msw query 兜底假 204（没删成，残留行致下轮 dup 400），真后端 `@RequestBody` 400 假红；同病波及 inspection-dictionary-write / report-names-write 两文件 | http.ts `http.delete(path, { headers, data: body })`；I07 前置清残留 + I08 补幂等二次 unlink 断言 |
| 4 | contract-test | axios 8s 超时 < nextjs dev 单次 login 实测 7.5-8s → 间歇误报 Unreachable | 超时 8s→30s（「声明即必须可达」判定不变，只是不再把 dev 编译慢当连不上） |
| 5 | 契约数据 | msw 种子 link 表 4 行同 SSOT 复合 PK（report_name_code 不在 PK）×4 变体、真库缺 `IP-0577/particle-gradation` 行（9-13 备份含之） | msw 种子去重保 RN-103-1（25→22）；lab_dev 补回缺行（22 对齐）；nextjs 侧发现 file: 依赖是安装时**真拷贝**，rm + npm install 刷新后对齐 |
| 6 | 契约校验 | `assertTimestampShape` 把 `""` 判非法，但 ADR-0025 全家族 `text().default("")` 未设时间戳是约定（四方含真库一致返回 `""`） | normalize.ts 放行 `""`（其余荒谬值照挡）+ 单测锁定 |

### 7.1 记录在案的后续候选（本 REQ 不做）

- **calculation-methods 路由疑似同款 nextjs 跨路由 bug**：live 期间观测到
  calculation-methods 清理失败（POST 后读不到），与 param-interfaces 修掉的
  per-route bundle 多副本指纹一致；修法同款 globalThis 单例，属另一 REQ/直接小修。
- unlink 幂等化是本次 unlink 探测对齐的副产品（springboot NSEE→404、aspnetcore
  KeyNotFound→404 均改幂等 204，四方一致），其余 6 组 junction unlink 未动。
- 结构性洞（skipIf(!live) 门绿=没测）见风险表，维持「本次不修」。
