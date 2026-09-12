# lab-management-system-shared Architecture

> 实验室管理（lab-management-system）家族的契约仓。回答三个问题：
> 1. shared 仓在 7 仓家族里怎么承担「双 SSOT」（API + DB schema）；
> 2. 5 段目录骨架里每一段放什么、各模块的 TypeSpec + Drizzle schema 怎么对齐；
> 3. 一次「改契约 → 6 仓同步」的核心流程怎么走、db-first 消费链怎么落地（ADR-0025/0026/0033）。

> **范围**：本文档只描述 *架构*（结构 / 边界 / 数据流 / 决策）。
> 编码细则见 [docs/conventions/](conventions/)（当前空），单决策的 ADR 见 [docs/adr/](adr/)（db-first 改造决策见父仓 [ADR-0025](../../../docs/adr/0025-shared-schema-first-drizzle.md)、[ADR-0026](../../../docs/adr/0026-cross-repo-consumer-staleness.md)、[ADR-0033](../../../docs/adr/0033-lab-family-align-saas-reform.md)），功能清单见 [docs/functions/function-tree.md](functions/function-tree.md)。
>
> 与父仓架构总览的关系见 [附录 A](#附录-a与父仓-docsarchitecturemd-的关系)。

---

## 0. 阅读路径

| 你是… | 直接看 |
|---|---|
| 新人，30 分钟搞懂本仓 | §1 → §2 → §3.1（tsp/main.tsp 入口） |
| 想改 API | §3.1 → §4（流程）→ §5（6 消费仓同步矩阵） |
| 想改 DB schema | §3.3 → §3.4 → §4.2（改一次 DB schema 工作流） |
| 想知道「为什么这样设计」 | §7（决策索引） → [ADR-0007](../../../docs/adr/0007-shared-sql-ssot.md) + [父仓 §3.1](../../../docs/ARCHITECTURE.md#31-双-ssotapi-契约--db-schema) |
| 想看术语定义 | §8 |

---

## 1. 角色与定位

**lab-management-system-shared 是 lab 家族 7 仓的契约唯一真源**：

```
                ┌─────────────────────────────────────────┐
                │       lab-management-system-shared       │
                │   API 契约 (TypeSpec)  +  DB schema     │
                │   emit: openapi.yaml + V*.sql           │
                └──┬────────┬────────┬────────┬────────┬──┘
                   │        │        │        │        │
        ┌──────────┘        │        │        │        └────────────┐
        ▼                   ▼        ▼        ▼                     ▼
   msw:5200           react   vue   nextjs   springboot    aspnetcore
   (mock 后端)        :5202   :5203  :5201    :5205         :5204
                              (前端×3)        (后端×2)
                              (前端×3)        (后端×2)
```

| 维度 | 角色 |
|---|---|
| **本质** | 纯契约仓：API 产出物 `generated/openapi/openapi.yaml`；DB 真源 `src/db/schema.ts`（物化产物 `drizzle/*.sql` 入 git） |
| **真源范围** | API 契约（TypeSpec）+ DB schema（Drizzle schema-first）= **双 SSOT**（ADR-0025，取代 ADR-0007 手写 SQL） |
| **消费方** | 6 个仓：`msw` / `react` / `vue` / `nextjs` / `springboot` / `aspnetcore` |
| **直接对接方式** | API：6 仓各自 `scripts/gen-shared.{sh,ts}` 调本仓 `npm run emit:openapi` 读 `generated/openapi/openapi.yaml`；DB：本仓 `db:migrate` 落真库，消费仓从真库 pull / scaffold（ADR-0033 阶段一） |
| **禁止事项** | 业务代码 / 语言专属产物 / npm runtime 依赖（drizzle 四件 devDep 豁免）/ 手写 openapi.yaml / 手改 `drizzle/*.sql`（详见本仓 [CLAUDE.md](../CLAUDE.md) §2） |

**最简定义**：「shared 仓不认识 React、Spring 或 .NET，它只产出一份 OpenAPI yaml + 一份 Drizzle schema」。

---

## 2. 目录骨架

本仓是 5 段式骨架的「契约仓」裁剪形态——无 `src/`（无业务代码）、无 Dockerfile（无运行时服务）：

```
lab-management-system-shared/
├── CLAUDE.md                        ← 入口：禁业务代码 / 禁语言产物 / 仅 devDep / 双 SSOT 范围
├── .harness/stack.json              ← 声明 stack=shared-typescript + L1/L3/L4 门
├── docs/
│   ├── functions/function-tree.md   ← BASE 树：M01-M06 模块 + F 级（不拆 I）
│   ├── adr/                         ← 本仓暂未起草独立 ADR
│   ├── design/                      ← 当前空（占位）
│   └── conventions/                 ← 当前空（占位）
├── tsp/                             ← API 契约 TypeSpec 真源
│   ├── main.tsp                     ← 入口 import（声明 11 个 model + 1 个 contract + 13 个 routes）
│   ├── models/                      ← 11 个 .tsp 文件（@discriminated 联合 + DTO 形状）
│   ├── routes/                      ← 13 个 .tsp 文件（@route 子 namespace + @get/@post op）
│   └── contracts/                   ← 跨端 bind 锚点（FrontendBindMeta）
├── src/db/schema.ts                 ← DB schema 真源（Drizzle 手写；25 表 + audit_action enum）
├── drizzle/
│   ├── 0000_target_ddl.sql          ← db:generate 物化的 baseline（与 lab_dev 实测一致）
│   └── meta/                        ← drizzle journal + snapshot（入 git；幂等门的对照物）
├── generated/
│   └── openapi/openapi.yaml         ← emit 产物（git tracked，6 仓 codegen 读它）
├── scripts/
│   ├── codegen/emit-openapi.ts      ← 调 `npx tsp compile .` 写到 generated/openapi
│   ├── migrate-db.mjs               ← drizzle-kit migrate 包装（SSOT → 目标 PG）
│   ├── rebaseline-db.mjs            ← 破坏性重建（先备份！）
│   └── check_drizzle_idempotent.py  ← L4.db.idempotent 门（generate 零 diff）
├── tests/
│   ├── fnReporter.ts                ← vitest 报告器（trace_cmd 引用）
│   ├── drizzle.replay.test.ts       ← shared 侧 L4：空库 push 全量重建 + 隔离/cascade 断言
│   └── snapshots/                   ← 未来快照（当前为空）
├── main.tsp                         ← 与 tsp/main.tsp 重复入口（备查）
├── tspconfig.yaml                   ← emit: @typespec/openapi3 → generated/openapi/
├── package.json                     ← 仅 devDep：@typespec/* + tsx + vitest
├── tsconfig.json
├── vitest.config.ts
├── openapitools.json
├── README.md
└── .state/session.json              ← 跨会话状态（/handoff 归档；历史含 V014 分叉决策）
```

### 2.1 顶层文件 vs 子目录

| 路径 | 角色 | git tracked |
|---|---|---|
| `tsp/main.tsp` 与 `main.tsp` | TypeSpec 入口（双份指代同一文件） | 是 |
| `tsp/{models,routes,contracts}/*.tsp` | API 契约片段 | 是 |
| `src/db/schema.ts` | DB schema 真源（手写 Drizzle） | 是（**人只改这份**） |
| `drizzle/0000_target_ddl.sql` + `meta/` | db:generate 物化产物 | 是（禁止手改） |
| `generated/openapi/openapi.yaml` | emit 产物 | 是（消费仓读它） |
| `scripts/codegen/emit-openapi.ts` | build-time 工具 | 是 |
| `scripts/migrate-db.mjs` | SSOT → PG 直推（migrate） | 是 |
| `scripts/rebaseline-db.mjs` | 破坏性重建（备份先行） | 是 |
| `scripts/check_drizzle_idempotent.py` | L4.db.idempotent 门 | 是 |
| `tests/drizzle.replay.test.ts` | L4 空库 push 重建断言 | 是 |
| `tests/snapshots/` | 未来快照（当前空） | 是 |
| `.state/session.json` | 跨会话状态（`/handoff` 写） | 是 |
| `node_modules/` | devDep 安装产物 | 否（`.gitignore`） |

### 2.2 5 段结构在 shared 仓的裁剪

父仓 [§2.3](../../../docs/ARCHITECTURE.md#23-仓库矩阵14-个仓各自-5-段结构) 规定的 5 段：

| 段 | 通用形态 | shared 仓裁剪 |
|---|---|---|
| `CLAUDE.md` | 入口 | 必填（≤ 60 行） |
| `.harness/stack.json` | 自描述 | `stack: shared-typescript`；声明 L1/L3/L4，无 L2（无运行时 lint） |
| `docs/{functions,adr,design,conventions}/` | 文档 | `functions/` 必填（BASE tree）；`adr/` 占位（暂未起草） |
| `scripts/` | gen-shared.{sh,ts} | 改为 `scripts/codegen/emit-openapi.ts` + `scripts/migrate-db.mjs` + `scripts/rebaseline-db.mjs`（shared 是产出方，不是消费方） |
| `src/` | 业务代码 | **不存在**（禁业务代码） |
| `tests/` | fnTest | 仅 `drizzle.replay.test.ts`（空库 push 重建）+ `fnReporter.ts` |

---

## 3. 核心模块

本仓模块切分完全对齐 [docs/functions/function-tree.md](functions/function-tree.md) 的 BASE 树。M01-M06 共 6 模块（含 1 个 M98 跨端镜像占位——见 §3.6）。

### 3.1 入口：tsp/main.tsp

`main.tsp` 是 TypeSpec 的 import 入口，把 11 个 model + 1 个 contract + 13 个 routes 平铺到根 namespace `Lab.Management.Shared`：

```tsp
// main.tsp 片段
import "@typespec/http";
import "@typespec/openapi3";
import "@typespec/rest";

import "./tsp/models/common.tsp";              // FlowStatus / FlowAction / ReceiptResult + FlowHistoryEntry
import "./tsp/models/contract.tsp";             // M02
import "./tsp/models/sample-receipt.tsp";       // M03
import "./tsp/models/sample.tsp";
import "./tsp/models/test-record.tsp";
import "./tsp/models/inspection-catalog.tsp";   // M04（brand/model/spec/grade）
import "./tsp/models/technical-requirement.tsp";// M04.F05
import "./tsp/models/audit-event.tsp";          // M01
import "./tsp/models/inspection-dictionary.tsp";// M06.F01-F04
import "./tsp/models/report-name.tsp";          // M06.F07
import "./tsp/models/calculation-method.tsp";   // M06.F05
import "./tsp/models/param-interface.tsp";      // M06.F08

import "./tsp/contracts/frontend-bind.tsp";     // M98 跨端 bind 锚点

import "./tsp/routes/auth.tsp";                 // M00/M01
import "./tsp/routes/contracts.tsp";            // M02
import "./tsp/routes/sample-receipts.tsp";      // M03.F01-F02/F09
import "./tsp/routes/samples.tsp";
import "./tsp/routes/test-records.tsp";
import "./tsp/routes/report-flow.tsp";          // M03.F05-F08
import "./tsp/routes/inspection-catalog.tsp";   // M04 四码表
import "./tsp/routes/technical-requirements.tsp";// M04.F05
import "./tsp/routes/summary.tsp";              // M05
import "./tsp/routes/inspection-dictionary.tsp";// M06.F01-F04
import "./tsp/routes/report-names.tsp";         // M06.F07
import "./tsp/routes/calculation-methods.tsp";  // M06.F05
import "./tsp/routes/param-interfaces.tsp";     // M06.F08

using TypeSpec.Http;

@service
@server("https://api.example.com", "Production")
@route("/api")
namespace Lab.Management.Shared;
```

**根 namespace 常驻 model**（main.tsp 直接定义）：

| Model | 用途 | 出现处 |
|---|---|---|
| `ErrorResponse` | 统一错误体（code + message + details） | 所有 op 返回 |
| `Page<T>` | 分页包装（items + page + pageSize + total） | 所有列表 op |
| `CreatedResponse` | 创建响应（`{ id: string }`） | 所有创建 op 备用 |

### 3.2 M01 合同（M02.F01）

**TypeSpec**：`tsp/routes/contracts.tsp`

```tsp
@route("/contracts")
@tag("contracts")
namespace Lab.Management.Shared.Contracts {
  @get op listContracts(...): Page<Contract> | ErrorResponse;     // I01
  @post op createContract(@body body: CreateContractRequest): Contract | ErrorResponse;  // I02
  @get @route("/{id}") op getContract(@path id: string): Contract | ErrorResponse;       // I03
  @put @route("/{id}") op updateContract(...): Contract | ErrorResponse;                // I04
  @delete @route("/{id}") op deleteContract(@path id: string): void | ErrorResponse;    // I05
}
```

**DB 真源**：[src/db/schema.ts](../src/db/schema.ts) 的 `contracts` 表

```ts
// schema.ts contracts 关键列（对应历史 V001，V014 后 status 为 TEXT）
contracts: pgTable("contracts", {
  id:            text("id").primaryKey(),
  contractCode:  text("contract_code").notNull(),
  status:        text("status").default("active").notNull(), // V014 后由 contract_status PG enum → TEXT
  createdAt:     text("created_at").default("").notNull(),
  updatedAt:     text("updated_at").default("").notNull(),
  // ...其余列 + (tenant_id, contract_code) 唯一索引
});
```

| F | TypeSpec 端点 | SQL 表 | model |
|---|---|---|---|
| M02.F01.I01 | `GET /api/contracts` | `contracts` | `Contract` |
| M02.F01.I02 | `POST /api/contracts` | 同上 | `CreateContractRequest` |
| M02.F01.I03 | `GET /api/contracts/{id}` | 同上 | `Contract` |
| M02.F01.I04 | `PUT /api/contracts/{id}` | 同上 | `UpdateContractRequest` |
| M02.F01.I05 | `DELETE /api/contracts/{id}` | 同上 | — |

### 3.3 M02 接样 / M03 记录（M03.F01-F09）

**TypeSpec 切分**：

| F | routes 文件 | namespace | 主要 op |
|---|---|---|---|
| M03.F01 接样管理 | `tsp/routes/sample-receipts.tsp` | `Lab.Management.Shared.Receipts` | list/create/update/delete receipts |
| M03.F02 任务分配 | 同上 | 同上 | `PUT /receipts/{id}/task` |
| M03.F03 数据录入 | `tsp/routes/test-records.tsp` + `tsp/routes/samples.tsp` | `TestRecords` + `Samples` | sample/record CRUD + `PATCH /test-records/{id}/verdict` |
| M03.F05 报告审核 | `tsp/routes/report-flow.tsp` | `Lab.Management.Shared.ReportFlow` | `POST /receipts/flow` |
| M03.F06 报告批准 | 同上 | 同上 | 同上（按 stage 过滤） |
| M03.F07 报告发放 | 同上 | 同上 | 同上 |
| M03.F08 报告归档 | 同上 | 同上 | 同上 |
| M03.F09 接样单详情 | `tsp/routes/sample-receipts.tsp` | `Receipts` | `GET /receipts/{id}` + `GET /receipts/{id}/history` |

**M03 流程 8 阶段**（`tsp/models/common.tsp::FlowStatus`）：

```tsp
enum FlowStatus {
  receiving,         // 接样
  task_assignment,   // 任务分配
  data_entry,        // 数据录入
  review,            // 审核
  approval,          // 批准
  issuance,          // 发放
  archived,          // 归档
  completed,         // 完成（终态）
}
```

**Schema 真源**（[src/db/schema.ts](../src/db/schema.ts)，历史 V002/V003 已随 ADR-0033 阶段一退役）：

| 表 | 关键字段 | FK |
|---|---|---|
| `sample_receipts` | `commission_code`（`(tenant_id, commission_code)` 联合唯一）/ `flow_status`（TEXT）/ `result` / `judgment_basis jsonb` / `flow_history jsonb` / `category_code`（FK → inspection_report_names） | `contract_id → contracts.id`（RESTRICT） |
| `samples` | `receipt_id` / `sample_code` | `receipt_id → sample_receipts.id` ON DELETE CASCADE |
| `test_records` | `sample_id` / `parameter_code` / `verdict` | `sample_id → samples.id` ON DELETE CASCADE |

**关键流程动作**：所有 4 个报告阶段（F05-F08）统一为 `POST /receipts/flow` 的 `FlowActionRequest`，由 `FlowAction` enum 区分（`submit` / `return` / `withdraw`）。这是「批量流程动作端点 + 列表按 stage 过滤」设计，避免每个阶段单独搞 4 套路由。

### 3.4 M03 检测项（M04 四码表 + F05 技术要求 + M06 字典 + F05/F07/F08）

#### 3.4.1 M04 基础数据（码表）

**TypeSpec**：`tsp/routes/inspection-catalog.tsp`（四码表结构同构）

```tsp
@route("/catalog") @tag("inspection-catalog")
namespace Lab.Management.Shared.Catalog {
  // M04.F09 牌号
  @get @route("/brands") op listBrands(...): Page<InspectionBrand> | ErrorResponse;
  @post @route("/brands") op createBrand(...): InspectionBrand | ErrorResponse;
  @put @route("/brands/{code}") op updateBrand(...): InspectionBrand | ErrorResponse;
  @delete @route("/brands/{code}") op deleteBrand(...): void | ErrorResponse;
  // M04.F06/F07/F08 同构（models/specs/grades）
}
```

**Schema 真源**：[src/db/schema.ts](../src/db/schema.ts)（4 张码表同构；tenant_id + `(tenant_id, code)` 唯一）

| 表 | F | 备注 |
|---|---|---|
| `inspection_brands` | M04.F09 | 牌号 |
| `inspection_models` | M04.F06 | 型号 |
| `inspection_specs` | M04.F07 | 规格 |
| `inspection_grades` | M04.F08 | 等级 |

#### 3.4.2 M04.F05 技术要求

**TypeSpec**：`tsp/routes/technical-requirements.tsp`（复合主键）

```tsp
@route("/technical-requirements")
namespace Lab.Management.Shared.TechnicalRequirements {
  @get op listTechnicalRequirements(...): TechnicalRequirement[] | ErrorResponse;
  // 复合主键 GET/PUT/DELETE: {inspectionObjectCode}/{inspectionParameterCode}/{judgmentStandardCode}
}
```

**Schema 真源**：[src/db/schema.ts](../src/db/schema.ts) `technicalRequirements`（复合主键；4 个历史 enum 列已 TEXT 化）

#### 3.4.3 M06 检测能力（专项/项目/参数/标准 + 字典 link）

**TypeSpec**：`tsp/routes/inspection-dictionary.tsp`（最大的一对多，含 4 张 junction 的 link/unlink/list）

```tsp
@route("/inspection") @tag("inspection-dictionary")
namespace Lab.Management.Shared.InspectionDictionary {
  // M06.F01/F02/F03/F04 各 CRUD
  // 4 张 junction：
  //   specialty↔object   object↔parameter   object↔standard   standard↔parameter
  // 各自 link/unlink/list（POST/DELETE/GET）
}
```

**Schema 真源**：[src/db/schema.ts](../src/db/schema.ts)（8 张表：4 字典 + 4 junction）

#### 3.4.4 M06.F05 计算方法 / M06.F07 报告名称 / M06.F08 参数界面

| F | routes | 表（schema.ts） | 关键设计 |
|---|---|---|---|
| M06.F05 计算方法 | `tsp/routes/calculation-methods.tsp` | `inspection_calculation_methods` | 复合主键 `(inspectionObjectCode, inspectionParameterCode)`；算法类型 + 公式；主键约束名保留 V017 前遗留名 `inspection_calculation_rules_pkey` |
| M06.F07 报告名称 | `tsp/routes/report-names.tsp` | `inspection_report_names` + 3 junction | `extFields` 模板 + 关联标准/参数 |
| M06.F08 参数界面 | `tsp/routes/param-interfaces.tsp` | `inspection_param_interfaces` + `inspection_param_interface_links` | 参数↔界面 link；主键约束名保留 V013 改表名前遗留名 `param_interfaces_pkey` |

### 3.5 M03 报告（M05.F01 汇总 + M05 仪表盘）

**TypeSpec**：`tsp/routes/summary.tsp`

```tsp
@route("/summary") @tag("summary")
namespace Lab.Management.Shared.Summary {
  @get op getReportSummary(...): SummaryData | ErrorResponse;     // M05.F01 按 categoryCode
  @get @route("/stats") op getDashboardStats(): DashboardStats | ErrorResponse;
}
```

**SQL 真源**：无新表——读 `sample_receipts` + `contracts` + `test_records` 现存表聚合。

### 3.6 M98 镜像（FrontendBindMeta 锚点）

**TypeSpec**：`tsp/contracts/frontend-bind.tsp`

跨端「bind 锚点」：前端开发期需要一个稳定的 schema 锚点供 emit-only 引用，后端不实现该端点（标注 `emit-only`）。`omit-unreachable-types: true` 配 `FrontendBindMeta` 防止 8 个 bind schema 被误删（详见 `session.json` `dont:` 列表）。

**重要**：本仓根 namespace 不属于 M00-M06 BASE 树，是 emit 工具产物。开放问题见 `session.json` `open_questions`：是否需在 react/vue 仓 orval.config.ts 加 tags filter 排除 `frontend-bind-meta`。

### 3.7 DB 模块映射总览

真源 = [src/db/schema.ts](../src/db/schema.ts)（Drizzle 手写，ADR-0025 schema-first）。
V001-V017 的 SQL 历史看 git log -- sql/（2026-09-13 ADR-0033 阶段一切换时删除）。

| 表 | TypeSpec model | 业务域 |
|---|---|---|
| `contracts` | Contract / ContractStatus | M02.F01 |
| `sample_receipts` | SampleReceipt / FlowStatus / ReceiptResult | M03.F01-F09 |
| `samples` | Sample | M03.F02/F03 |
| `test_records` | TestRecord | M03.F03 |
| `inspection_brands` | InspectionBrand | M04.F09 |
| `inspection_models` | InspectionModel | M04.F06 |
| `inspection_specs` | InspectionSpec | M04.F07 |
| `inspection_grades` | InspectionGrade | M04.F08 |
| `inspection_technical_requirements` | TechnicalRequirement + 4 enum | M04.F05 |
| `audit_events` | AuditEvent / AuditAction | M01.F04/F05 |
| `inspection_specialties` + `inspection_objects` + 4 junction | InspectionSpecialty / Object / Parameter / Standard + 4 junction | M06.F01-F04 |
| `inspection_report_names` + 3 junction + `inspection_calculation_methods` | InspectionReportName + 3 junction + CalculationMethod | M06.F05/F07 |
| `inspection_param_interfaces` + `inspection_param_interface_links` | ParamInterface + link | M06.F08 |
| `audit_action`（仅 PG enum） | AuditAction | M01 |

**enum 值域**：V014（历史迁移）把 12 个业务 PG enum 全部转 TEXT，值域校验由 TypeSpec/OpenAPI 层兜底；
仅 `audit_action` 保留 PG enum。schema.ts 里体现为 text 列 + 单个 `pgEnum`。

---

## 4. 核心流程

### 4.1 改一次 TypeSpec → 6 仓同步

```
1. [shared] 改 tsp/main.tsp 或子文件（models/routes/contracts 任一）
   ↓ git commit + push

2. [shared] npm run build
   ├─ npm run emit:openapi → tsp compile → generated/openapi/openapi.yaml
   └─ npx tsc --noEmit        ← L3 类型检查
   ↓

3. [shared] python scripts/gate.py -p lab-management-system-shared
   ├─ L1: tsp compile --no-emit       ← 语法格式
   ├─ L3: tsc --noEmit                ← 类型
   ├─ L4: vitest run                  ← drizzle.replay.test（空库 push 重建 + 断言）
   └─ L4.db.idempotent: check_drizzle_idempotent.py   ← drizzle-kit generate 零 diff
   ↓ exit 0

4. [msw / react / vue / nextjs / springboot / aspnetcore]
   bash scripts/gen-shared.{sh,ts}
   固定 3 步：
   a) (cd ../shared && npm run emit:openapi)
   b) 本地 codegen：openapi-generator (java) / NSwag (C#) / orval (TS)
   c) DB 契约消费（ADR-0025/0026）：nextjs drizzle-kit pull / springboot+aspnetcore
      从真库 scaffold / msw 类型 pull——不再拷贝任何 SQL 文件
   ↓ git commit + push（每个仓各自 tag v<X>-<YYYYMMDD>）

5. [父仓] git update-index --add --cacheinfo 160000,<NEW_HASH>,output/<proj>
   chore(submodule): 推进 <proj> 指针
   ↓ git push

6. [suite] python scripts/gate.py --all
   ↓ 14 项目全绿
```

**关键检查点**：

- TypeSpec 改完必须**先**在 BASE tree 加 F（[ADR-0003](../../../docs/adr/0003-function-tree-requires-human-approval.md)），再改本仓 + 6 仓；否则 L5 红（"已上线但无 BASE 引用"告警）；
- `npm run emit:openapi` 自动 bootstrap devDep（fresh clone 时本地没装 @typespec/compiler 也能跑，见 [scripts/codegen/emit-openapi.ts](../scripts/codegen/emit-openapi.ts) L13-19 注释）；
- `tspconfig.yaml` 用 `omit-unreachable-types: true`，**必须配 `FrontendBindMeta`** 锚点防 8 schema 被误丢。

### 4.2 改一次 DB schema → 6 仓同步

```
1. [shared] 改 src/db/schema.ts（人只改这一份）
   ↓ git commit + push

2. [shared] npm run db:generate
   ├─ drizzle-kit generate → drizzle/000N_*.sql + meta/（入 git）
   └─ 零 diff 未物化 → L4.db.idempotent 红
   ↓

3. [shared] python scripts/gate.py -p lab-management-system-shared
   L4: vitest run
   ├─ drizzle.replay.test.ts: 空库 drop schema → drizzle-kit push 全量重建
   ├─ 断言 25 张表 + audit_action enum + 租户隔离列 + junction PK + cascade 链
   └─ 通过 → exit 0
   ↓

4. [推到 dev DB（不走 6 仓中转）]
   PG_DATABASE=lab_dev node scripts/migrate-db.mjs    # 增量 apply（__drizzle_migrations tracking）
   node scripts/rebaseline-db.mjs                     # 破坏性重建（先备份！）
   ↓

5. [消费仓从真库反向工程（ADR-0033 阶段一）]
   nextjs:     bash scripts/pull-schema.sh            # drizzle-kit pull → src/db/schema.ts（git + drift 检测）
   springboot: bash scripts/scaffold-entities.sh      # JDBC 反向工程 → Generated/ entity
   aspnetcore: bash scripts/scaffold-dbcontext.sh     # dotnet ef dbcontext scaffold → Generated/
   msw:        bash scripts/pull-schema.sh            # type-only（handler/seed 列类型）
   ↓

6. [react / vue] 无操作（前端无 DB 产物）
```

**关键检查点**：

- 禁止手改 `drizzle/*.sql`——迁移只能由 `db:generate` 产出（L4.db.idempotent 锁）；
- 改了 `schema.ts` 没跑 `db:generate` → generate 出 diff → 门红；
- 破坏性重建必须先做全量 JSON 备份（`backups/` 有先例；rebaseline 脚本 prod 双闸）；
- shared 仓禁 npm runtime 依赖，`pg` driver 从相邻 `lab-management-system-nextjs/node_modules/pg` 借（详见 §3.8）；
- L4 跳过条件：`PG_REPLAY_SKIP=1`（CI 默认跑；本地无 PG 可跳）。

### 4.3 同步矩阵汇总

| 操作 | shared | msw | react / vue / nextjs | springboot | aspnetcore |
|---|---|---|---|---|---|
| 改 TypeSpec | emit:openapi → openapi.yaml | 调 emit + 重启 handlers | 调 emit + orval codegen | 调 emit + openapi-generator | 调 emit + NSwag |
| 改 DB schema | db:generate + L4 replay + migrate | pull-schema（type-only） | nextjs: pull-schema；react/vue 无 | scaffold-entities | scaffold-dbcontext |
| 推 dev DB | migrate-db.mjs 直推 | 无 | 无 | 重启 / mvn spring-boot:run | 启动 dotnet |

### 4.4 门禁链

```
python scripts/gate.py -p lab-management-system-shared
  ↓
L0 结构完整性（suite 拥有）
  ├─ 必需目录存在：tsp/、src/db/、drizzle/、generated/openapi/、scripts/、tests/、.harness/stack.json
  └─ exit 1 = 结构错
  ↓
L1 格式（项目声明）
  └─ npx tsp compile . --no-emit         ← TypeSpec 语法
  ↓
L2 静态检查（项目未声明，跳过）
  ↓
L3 类型/编译（项目声明）
  └─ npx tsc --noEmit
  ↓
L4 测试（项目声明 + trace_cmd）
  ├─ npx vitest run
  └─ vitest 默认不开 trace_cmd；但可配 TRACE_MAP=1 走 fnReporter 产 .state/trace.json
  ↓
L5 引用完整性（suite 拥有）
  ├─ 测试 fn-ID 必须引用已存在的 F/I
  └─ 已上线 F 必须被至少 1 个测试引用

exit 0 = 全绿；1 = 按 fix 提示回代码改；2 = 契约/环境问题（停下问人）
```

**关键规则**：

- 本仓 `stack.json` 只声明 L1/L3/L4（L0/L5 是 suite 保留，[ADR-0001](../../../docs/adr/0001-suite-owns-l0-and-l5.md)）；
- L4 的 `drizzle.replay.test.ts` 是契约仓独有的「空库 push 重建」门禁——等价于后端的集成测试，但跑在 shared 仓测试 PG 上；`L4.db.idempotent` 锁 schema.ts ↔ drizzle/ 快照零 diff；
- `trace_cmd = ["npx", "--no", "vitest", "run"]` + `TRACE_MAP=1` 触发 fnReporter 产 `.state/trace.json`（与跨语言锚点 [ADR-0002](../../../docs/adr/0002-trace-json-as-cross-language-anchor-contract.md) 一致）。

---

## 5. 契约消费矩阵：6 个消费仓怎么读本仓

| 消费仓 | 读 openapi.yaml | DB 契约消费方式（ADR-0033 阶段一） | 同步脚本 | codegen 工具 |
|---|---|---|---|---|
| `lab-msw` | 调 emit 后由 handlers 手工对齐 fixture | `pull-schema.sh` type-only（handler/seed 列类型） | `gen-shared.ts` 调 emit + 重启 server | 无（手写 handler shape） |
| `lab-react` | 同上 + orval codegen | 无 DB 产物 | `gen-shared.ts` 訓 emit + orval | orval + axios |
| `lab-vue` | 同上 | 无 DB 产物 | `gen-shared.ts` 调 emit + orval | orval + axios + Pinia |
| `lab-nextjs` | 同上 + orval | `pull-schema.sh`：drizzle-kit pull 真库 → `src/db/schema.ts`（git + drift 检测） | `gen-shared.sh` 调 emit + orval；`pull-schema.sh` 独立 | orval + axios + drizzle |
| `lab-springboot` | 同上 + openapi-generator | `scaffold-entities.sh`：JDBC 反向工程 → `Generated/` entity（Flyway 弃用） | `gen-shared.sh` 调 emit + codegen；scaffold 独立 | openapi-generator-cli（java）+ 自研 scaffold |
| `lab-aspnetcore` | 同上 + NSwag | `scaffold-dbcontext.sh`：`dotnet ef dbcontext scaffold` → `Generated/`（禁 EF Migrations） | `gen-shared.sh` 调 emit + NSwag；scaffold 独立 | NSwag（C#）+ dotnet ef scaffold |

### 5.1 springboot 专属：弃 Flyway 走 DB-First scaffold

springboot 弃用 Flyway（原 `DIVERGED_VERSIONS` 白名单机制随之删除）。entity 真相从真库反向工程：
`scaffold-entities.mjs` 读 `information_schema` 产 `Generated/<Table>.Java`，手写逻辑经继承叠加，
DB 变更后重跑 scaffold + git diff 漂移检测。

### 5.2 nextjs 专属：pull 真库 schema

`lab-management-system-nextjs` 的 `src/db/schema.ts` 是真库镜像（入 git）：

- **pull-schema.sh**：`drizzle-kit pull` 真库 → 产物 move 到 `src/db/schema.ts` → `git diff` drift 检测，不一致 exit 1；
- **借 `pg` driver**：shared 侧 `tests/drizzle.replay.test.ts` 通过 `createRequire("../lab-management-system-nextjs/package.json")` 借 nextjs 仓的 `node_modules/pg`（shared 仓禁 runtime 依赖）。

### 5.3 msw / 前端专属：只读 openapi.yaml

msw 与 3 个前端仓的契约消费只走 openapi.yaml：

```
shared/generated/openapi/openapi.yaml
  ↓ orval (前端) / 手写 shape (msw handlers)
src/api/endpoints/*.ts    ← 前端 codegen 产物
src/handlers-array.ts     ← msw 手写 handler shape
```

不读 SQL。fixture 用 in-memory JSON。

---

## 6. 历史：V014 分叉与 Flyway 时代（已终结）

### 6.1 结论

「V014 永久分叉」是 Flyway/SQL 真源时代的结构性问题，**已随 ADR-0033 阶段一（db-first 改造）整体消亡**：

- shared 仓不再持有 `sql/migrations/V001-V017`，DDL 真源切换为 [src/db/schema.ts](../src/db/schema.ts)（ADR-0025）；
- springboot 仓同步弃用 Flyway（`db/migration/` 演化链 + `DIVERGED_VERSIONS` 白名单一并删除），
  改走 DB-first scaffold（saas 模式）；
- 消费仓与 shared 之间的「V 文件逐字节拷贝 + checksum 对齐」机制整体退役，
  换成 ADR-0026 的 `.state/last-gen-shared.json` 陈旧度标记（`api_synced_sha` / `db_synced_sha`）。

### 6.2 当年是什么问题

shared 的 V014（`ALTER TABLE inspection_calculation_rules ...`）与 springboot 的 V014（表已改名 `inspection_calculation_methods`）内容不同但终态等价——两条迁移链命名共享版本号、内容差异化，fresh replay 链与演化链不可互换（详见 git 历史的 `sql/migrations/V014`/`V017` 与 `.state/session.json` 归档）。

### 6.3 幸存的遗产

| 遗产 | 现状 |
|---|---|
| 12 个业务 enum → TEXT 化 | 保留在 schema.ts 终态里（仅 `audit_action` 一个 PG enum） |
| 遗留约束名 `param_interfaces_pkey` / `inspection_calculation_rules_pkey` | schema.ts 显式保留（`primaryKey({ name })`），与 lab_dev 实测一致 |
| 撞号事故教训（2026-08-26 flyway checksum） | 附录 C 陷阱表保留一行，作为「为什么迁移必须从真源生成」的反面教材 |

---

## 7. 决策索引

本仓暂未起草独立 ADR（`docs/adr/` 占位）。决策引用全部走父仓 ADR：

### 7.1 直接相关

| ADR | 主题 | 与本仓关系 |
|---|---|---|
| [ADR-0007](../../../docs/adr/0007-shared-sql-ssot.md) | shared 仓扩到双 SSOT | 双 SSOT 定位源头；已被 ADR-0025 部分取代（DB 侧从 SQL 换 Drizzle） |
| [ADR-0025](../../../docs/adr/0025-shared-schema-first-drizzle.md) | shared schema-first（Drizzle SSOT） | **本仓 DB 侧现状**：`src/db/schema.ts` 真源 + `drizzle/` 物化 + L4.db.idempotent 零 diff 门 |
| [ADR-0026](../../../docs/adr/0026-cross-repo-consumer-staleness.md) | 消费仓陈旧度标记 | 消费仓 `.state/last-gen-shared.json` 双字段（api/db synced_sha），取代 V 文件逐字节对齐 |
| [ADR-0033](../../../docs/adr/0033-lab-family-align-saas-reform.md) | lab 家族对齐 saas 改造 | **总纲**：三阶段（db-first → 白名单清零 → e2e 仓）；本仓阶段一已落地 |
| [ADR-0009](../../../docs/adr/0009-db-credentials-env.md) | DB 凭据走 env | `migrate-db.mjs` / `rebaseline-db.mjs` / drizzle.config.ts 的 PG_* env 来源（禁默认值兜底） |

### 7.2 间接相关

| ADR | 主题 | 与本仓关系 |
|---|---|---|
| [ADR-0001](../../../docs/adr/0001-suite-owns-l0-and-l5.md) | suite 保留 L0/L5 | 本仓 stack.json 只声明 L1/L3/L4 |
| [ADR-0002](../../../docs/adr/0002-trace-json-as-cross-language-anchor-contract.md) | trace.json 跨语言锚点 | L4 trace_cmd 触发 fnReporter 产 `.state/trace.json` |
| [ADR-0003](../../../docs/adr/0003-function-tree-requires-human-approval.md) | 功能清单变更需人批 | BASE tree 改 F 必须 `/tree-change` 提案（ADR-0033 阶段二白名单清零也走这个流程） |
| [ADR-0012](../../../docs/adr/0012-msw-as-http-server.md) | msw 升级为独立 HTTP 服务 | 决定本仓 emit 的 openapi.yaml 是 msw 仓 fixture 的唯一依据 |
| [ADR-0014](../../../docs/conventions/multi-repo-family.md#4-后端配置env-driven-单-urladr-0014) | env-driven 单 URL | 6 仓前端读 openapi.yaml 时走同一 baseURL 配置 |
| [ADR-0029](../../../docs/adr/0029-consumer-cannot-unilaterally-modify-shared.md) | 消费仓禁单方面改 shared | 消费仓发现「本仓需要 ≠ shared」必须列候选方案停下问人 |

### 7.3 待起草（next）

- 本仓 ADR：「FrontendBindMeta / M98 镜像」（emit-only 锚点不被后端实现的语义）。

详见 ``.state/session.json`` `open_questions[]`。

---

## 8. 术语表

| 术语 | 含义 | 详细 |
|---|---|---|
| **双 SSOT** | shared 仓同时是 API + DB schema 真源 | 本仓 `tsp/` + `src/db/schema.ts`（ADR-0007 定位、ADR-0025 落地） |
| **BASE tree** | 契约仓的功能清单（只到 F） | [docs/functions/function-tree.md](functions/function-tree.md) |
| **OpenAPI yaml** | TypeSpec emit 出来的 API 契约 | `generated/openapi/openapi.yaml` |
| **schema-first** | DB DDL 真源 = 手写 Drizzle schema.ts，迁移由 `db:generate` 物化 | ADR-0025；[src/db/schema.ts](../src/db/schema.ts) + `drizzle/` |
| **target DDL** | `drizzle/0000_target_ddl.sql`——当前终态的全量 DDL | 禁手改；改 schema.ts 后 `npm run db:generate` 再生成 |
| **push 重建** | 空库 `drizzle-kit push --force` 全量重建 + 断言 | `tests/drizzle.replay.test.ts`（替代旧 fresh replay 链） |
| **V 文件**（历史） | Flyway 风格 DDL 真源，2026-09-13 随 ADR-0033 阶段一退役 | §6；git 历史可考古 |
| **emit-only** | TypeSpec 定义但后端不实现，只作 codegen 锚点 | `FrontendBindMeta` / `/_frontend-bind/snapshot` |
| **migrate-db** | SSOT → PG 直推（drizzle-kit migrate，非破坏） | [scripts/migrate-db.mjs](../scripts/migrate-db.mjs) |
| **rebaseline** | 破坏性 DROP SCHEMA + 重建（备份先行） | [scripts/rebaseline-db.mjs](../scripts/rebaseline-db.mjs) |
| **借 pg driver** | shared 仓借 nextjs 仓的 `node_modules/pg`（禁 runtime 依赖） | `createRequire("../lab-management-system-nextjs/package.json")` |
| **陈旧度标记** | 消费仓 `.state/last-gen-shared.json` 记 api/db synced_sha | ADR-0026；取代旧 V 文件逐字节对齐 |
| **omit-unreachable-types** | TypeSpec 编译选项：未引用类型不 emit | `tspconfig.yaml` |
| **stack.json** | 项目自描述（栈 + 门配置） | `.harness/stack.json`；项目只声明 L1/L3/L4（L4.db.idempotent 是 drizzle 零 diff 门） |
| **V014 永久分叉**（历史） | Flyway 时代 shared 与 springboot 的 V014 内容不同但终态等价 | 已随 Flyway 退役消亡，§6 |

---

## 附录 A：与父仓 docs/ARCHITECTURE.md 的关系

| 父仓文档章节 | 本仓文档对应章节 | 关系 |
|---|---|---|
| [§1 套件全景](../../../docs/ARCHITECTURE.md#1-套件全景) | §1 | 父仓列 14 仓全貌；本仓只 zoom in 自己 |
| [§2.1 五种角色](../../../docs/ARCHITECTURE.md#21-五种角色) | §1 | 父仓「契约仓 = 1 仓/家族」；本仓细化双 SSOT 职责 |
| [§2.3 5 段式骨架](../../../docs/ARCHITECTURE.md#23-仓库矩阵14-个仓各自-5-段结构) | §2 | 父仓列出通用形态；本仓列裁剪后形态（无 src/） |
| [§3.1 双 SSOT](../../../docs/ARCHITECTURE.md#31-双-ssotapi-契约--db-schema) | §3 + §4.2 | 父仓给出双 SSOT 原则；本仓给具体落地（schema.ts + 25 张表；db-first 消费链见 §5） |
| [§3.2 一份契约，三套 codegen](../../../docs/ARCHITECTURE.md#32-一份契约三套-codegen) | §5 | 父仓列 codegen 链总览；本仓列 6 仓逐个怎么读 |
| [§3.7 Function Tree 是跨端对齐索引](../../../docs/ARCHITECTURE.md#37-function-tree-是-跨端对齐的索引) | §3.7 | 父仓解释 BASE + 各仓镜像；本仓 BASE 只到 F |
| [§4.1 契约仓职责详解](../../../docs/ARCHITECTURE.md#41-契约仓shared-2) | §3 + §4 | 父仓给出契约仓通用职责；本仓列具体模块切分 |
| [§5.1 改一次契约 → 三端同步](../../../docs/ARCHITECTURE.md#51-改一次契约--三端同步codegen-链) | §4.1 | 父仓给三步流程；本仓给 shared 视角的完整链 |
| [§7 决策索引](../../../docs/ARCHITECTURE.md#7-决策索引) | §7 | 父仓列 12 份 ADR；本仓引用 + 标注本仓特有待起草 |

**本文档与父仓 ARCHITECTURE.md 的边界**：

- 父仓文档是 **suite 级** ——回答「14 仓怎么组织、3 端怎么同步、端口 + CORS 怎么对齐」；
- 本文档是 **shared 仓级** ——回答「本仓内部怎么组织、TypeSpec + Drizzle schema 怎么对齐、db-first 消费链怎么走」；
- 本文档**不重复**父仓已说明的端口 / CORS / env / multi-repo-family 等通用约定；
- 本文档**会 zoom in** 到本仓特有的话题（schema-first 工作流、M98 镜像、emit-openapi bootstrap、Flyway 时代历史归档）。

---

## 附录 B：相关约定 / 决策 / 文档

- 父仓架构总览：[`docs/ARCHITECTURE.md`](../../../docs/ARCHITECTURE.md)
- 父仓多仓家族约定：[`docs/conventions/multi-repo-family.md`](../../../docs/conventions/multi-repo-family.md)
- 父仓 submodule 操作：[`docs/conventions/submodule.md`](../../../docs/conventions/submodule.md)
- 父仓 ADR 索引：[`docs/adr/`](../../../docs/adr/)（本仓直接相关：ADR-0025/0026/0033）
- 本仓入口：[`CLAUDE.md`](../CLAUDE.md)
- 本仓功能清单：[`docs/functions/function-tree.md`](functions/function-tree.md)
- 本仓跨会话状态：``.state/session.json``
- 父仓跨会话经验：`~/.claude/projects/.../memory/MEMORY.md`（非入仓）

## 附录 C：本仓典型陷阱

| 陷阱 | 后果 | 解法 |
|---|---|---|
| 手写 `generated/openapi/openapi.yaml` | L1 红 + L4 类型不一致 | 必须 `npm run build` → `emit:openapi` |
| 手改 `src/db/schema.ts` 之外直接改 `drizzle/*.sql` | L4.db.idempotent 红（generate 出 diff） | 只改 schema.ts，再 `npm run db:generate` |
| 手写迁移 SQL / 引入 Flyway、EF Migrations | 违反 ADR-0025 + [CLAUDE.md](../CLAUDE.md) §2 铁律 | 迁移只能由 `db:generate` 产出；重建走 `rebaseline-db.mjs` |
| Flyway 时代教训：手改已落地迁移文件 | checksum 撞号 + 历史库炸（2026-08-26 事故） | schema-first 后迁移产物可再生；历史教训保留作反面教材（§6.3） |
| 借不到 pg driver | replay 测试 skip（假绿） | dev 环境先在 nextjs 仓 `npm install`；CI 需 PG_* env 齐，否则该测试显式 skip |
| 删除 `FrontendBindMeta` 锚点 | 8 schema 被 `omit-unreachable-types` 丢 | 锚点必须留作 emit-only |
| `package.json` `exports` 暴露语言路径（如 `./api-client`） | 违反 [CLAUDE.md](../CLAUDE.md) §2 | 仅暴露 `./openapi` yaml 路径 |
| 改 F 级但不先改 BASE tree | L5 红 + 6 仓 I 级无 BASE 引用 | 改 F 必须先 `/tree-change` |
| 启动 L4 时本地无 PG | `vitest` 跑挂在 `pgModule` null | 配 `PG_REPLAY_SKIP=1` 跳过；或启本地 PG |
| `.primaryKey({ name })` 写在列级 | drizzle-kit 0.28 静默忽略，遗留约束名丢 | 复合/命名主键写表级第三参数 `primaryKey({ columns, name })` |
| `@discriminated("kind")` 字符串参数 | v1.15 是 object 参数，编译报错 | 写 `@discriminated`（无参）即可 |
| model 上挂方法 | TypeSpec 不允许 | 改 namespace 级 op 或纯数据 model + doc 注释 |
| namespace 下裸 op 声明 | 自动当 HTTP 路由撞 `duplicate-operation` | 套 `@route` 子 namespace |
