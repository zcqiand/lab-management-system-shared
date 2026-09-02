# lab-management-system-shared Architecture

> 实验室管理（lab-management-system）家族的契约仓。回答三个问题：
> 1. shared 仓在 7 仓家族里怎么承担「双 SSOT」（API + DB schema）；
> 2. 5 段目录骨架里每一段放什么、各模块的 TypeSpec + SQL 怎么对齐；
> 3. 一次「改契约 → 6 仓同步」的核心流程怎么走、V014 永久分叉怎么落地。

> **范围**：本文档只描述 *架构*（结构 / 边界 / 数据流 / 决策）。
> 编码细则见 [docs/conventions/](conventions/)（当前空），单决策的 ADR 见 [docs/adr/](adr/)（本仓暂未起草独立 ADR，引用父仓 [ADR-0007](../../../docs/adr/0007-shared-sql-ssot.md)），功能清单见 [docs/functions/function-tree.md](functions/function-tree.md)。
>
> 与父仓架构总览的关系见 [附录 A](#附录-a与父仓-docsarchitecturemd-的关系)。

---

## 0. 阅读路径

| 你是… | 直接看 |
|---|---|
| 新人，30 分钟搞懂本仓 | §1 → §2 → §3.1（tsp/main.tsp 入口） |
| 想改 API | §3.1 → §4（流程）→ §5（6 消费仓同步矩阵） |
| 想改 DB schema | §3.3 → §3.4 → §4 → §6（V014 永久分叉） |
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
| **本质** | 纯契约仓：唯一产出物是 `generated/openapi/openapi.yaml` + `sql/migrations/*.sql` |
| **真源范围** | API 契约（TypeSpec）+ DB schema（Flyway 风格 SQL）= **双 SSOT**（[ADR-0007](../../../docs/adr/0007-shared-sql-ssot.md)） |
| **消费方** | 6 个仓：`msw` / `react` / `vue` / `nextjs` / `springboot` / `aspnetcore` |
| **直接对接方式** | 6 仓各自 `scripts/gen-shared.{sh,ts}` 调本仓 `npm run emit:openapi` + 读 `generated/openapi/openapi.yaml` + `cp sql/migrations/*.sql` 到仓内 |
| **禁止事项** | 业务代码 / 语言专属产物 / npm runtime 依赖 / 手写 openapi.yaml（详见本仓 [CLAUDE.md](../CLAUDE.md) §2） |

**最简定义**：「shared 仓不认识 React、Spring 或 .NET，它只产出一份 OpenAPI yaml + 一份 SQL 迁移序列」。

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
├── sql/                             ← DB schema 真源
│   ├── README.md                    ← 命名约定 + 表/V 文件映射 + 各后端消费方式
│   └── migrations/                  ← V001..V017（Flyway 风格；V014 永久分叉）
│       ├── V001__init_contracts.sql
│       ├── V002..V013 ...           ← 主干：13 表 + 9 字典 + 4 junction
│       ├── V014__enums_to_text.sql  ← 12 enum → TEXT（永久分叉）
│       ├── V015__smoke_seed_dict.sql
│       └── V017__rename_calculation_rules_to_methods.sql
├── generated/
│   └── openapi/openapi.yaml         ← emit 产物（git tracked，6 仓 codegen 读它）
├── scripts/
│   ├── codegen/emit-openapi.ts      ← 调 `npx tsp compile .` 写到 generated/openapi
│   └── sync-db.mjs                  ← 跨仓 sync-db 工具（直推 SSOT → 目标 PG）
├── tests/
│   ├── fnReporter.ts                ← vitest 报告器（trace_cmd 引用）
│   ├── sql.replay.test.ts           ← shared 侧 L4：fresh replay 链等价性
│   └── snapshots/                   ← 未来快照（当前为空）
├── main.tsp                         ← 与 tsp/main.tsp 重复入口（备查）
├── tspconfig.yaml                   ← emit: @typespec/openapi3 → generated/openapi/
├── package.json                     ← 仅 devDep：@typespec/* + tsx + vitest
├── tsconfig.json
├── vitest.config.ts
├── openapitools.json
├── README.md
└── .state/session.json              ← 跨会话状态（V015/V017 收敛 / V014 永久分叉决策）
```

### 2.1 顶层文件 vs 子目录

| 路径 | 角色 | git tracked |
|---|---|---|
| `tsp/main.tsp` 与 `main.tsp` | TypeSpec 入口（双份指代同一文件） | 是 |
| `tsp/{models,routes,contracts}/*.tsp` | API 契约片段 | 是 |
| `sql/migrations/V*.sql` | DB schema 迁移 | 是（**只增不修**） |
| `generated/openapi/openapi.yaml` | emit 产物 | 是（消费仓读它） |
| `scripts/codegen/emit-openapi.ts` | build-time 工具 | 是 |
| `scripts/sync-db.mjs` | 跨仓 sync-db 工具 | 是 |
| `tests/sql.replay.test.ts` | L4 fresh replay 链断言 | 是 |
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
| `scripts/` | gen-shared.{sh,ts} | 改为 `scripts/codegen/emit-openapi.ts` + `scripts/sync-db.mjs`（shared 是产出方，不是消费方） |
| `src/` | 业务代码 | **不存在**（禁业务代码） |
| `tests/` | fnTest | 仅 `sql.replay.test.ts`（fresh replay 链）+ `fnReporter.ts` |

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

**SQL 真源**：`V001__init_contracts.sql`

```sql
-- V001 关键列
CREATE TABLE contracts (
  id           text PRIMARY KEY,
  contract_code text NOT NULL UNIQUE,
  client_unit  text NOT NULL,
  project_name text NOT NULL,
  construction_unit text,
  witness_unit text,
  witness      text,
  status       text NOT NULL DEFAULT 'active',  -- V014 后由 contract_status PG enum → TEXT
  created_at   text NOT NULL DEFAULT '',
  updated_at   text NOT NULL DEFAULT ''
);
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

**SQL 真源**：

| 表 | V 文件 | 关键字段 | FK |
|---|---|---|---|
| `sample_receipts` | V002 | `commission_code`（V012 后 `(tenant_id, commission_code)` 联合唯一） / `flow_status`（V014 后 TEXT）/ `result` / `judgment_basis jsonb` / `flow_history jsonb` / `category_code`（FK → inspection_report_names） | `contract_id → contracts.id`（RESTRICT） |
| `samples` | V002 | `receipt_id` / `sample_code` | `receipt_id → sample_receipts.id` ON DELETE CASCADE |
| `test_records` | V003 | `sample_id` / `parameter_code` / `verdict` | `sample_id → samples.id` ON DELETE CASCADE |

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

**SQL 真源**：`V004__init_inspection_catalog.sql`（4 张码表同构）

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

**SQL 真源**：`V005__init_technical_requirements.sql`（4 个 enum → V014 转 TEXT）

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

**SQL 真源**：`V008__init_inspection_dictionary.sql`（8 张表：4 字典 + 4 junction）

#### 3.4.4 M06.F05 计算方法 / M06.F07 报告名称 / M06.F08 参数界面

| F | routes | V 文件 | 关键设计 |
|---|---|---|---|
| M06.F05 计算方法 | `tsp/routes/calculation-methods.tsp` | V009（`inspection_calculation_methods`）→ V017 rename | 复合主键 `(inspectionObjectCode, inspectionParameterCode)`；算法类型 + 公式 |
| M06.F07 报告名称 | `tsp/routes/report-names.tsp` | V009（5 张：name + 3 junction） | `extFields` 模板 + 关联标准/参数 |
| M06.F08 参数界面 | `tsp/routes/param-interfaces.tsp` | V010（2 张：interface + link），V013 rename tables | 参数↔界面 link |

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

### 3.7 SQL 模块映射总览

按 [sql/README.md](../sql/README.md)「Migrations」段：

| 表 | V 文件 | TypeSpec model | 业务域 |
|---|---|---|---|
| `contracts` | V001 | Contract / ContractStatus | M02.F01 |
| `sample_receipts` | V002 | SampleReceipt / FlowStatus / ReceiptResult | M03.F01-F09 |
| `samples` | V002 | Sample | M03.F02/F03 |
| `test_records` | V003 | TestRecord | M03.F03 |
| `inspection_brands` | V004 | InspectionBrand | M04.F09 |
| `inspection_models` | V004 | InspectionModel | M04.F06 |
| `inspection_specs` | V004 | InspectionSpec | M04.F07 |
| `inspection_grades` | V004 | InspectionGrade | M04.F08 |
| `inspection_technical_requirements` | V005 | TechnicalRequirement + 4 enum | M04.F05 |
| `audit_events` | V006 | AuditEvent / AuditAction | M01.F04/F05 |
| `inspection_specialties` + `inspection_objects` + 4 junction | V008 | InspectionSpecialty / Object / Parameter / Standard + 4 junction | M06.F01-F04 |
| `inspection_report_names` + 3 junction + `inspection_calculation_methods` | V009 | InspectionReportName + 3 junction + CalculationMethod | M06.F05/F07 |
| `inspection_param_interfaces` + `inspection_param_interface_links` | V010→V013 rename | ParamInterface + link | M06.F08 |
| `audit_action`（仅 PG enum，未转 TEXT） | V006 | AuditAction | M01（springboot B1 未接入） |

**V014 转换的 12 个 enum**（V001/V002/V005/V008/V009 引入 → V014 一次性 DROP TYPE CASCADE）：

| Enum | 来源 V | 引用表 |
|---|---|---|
| `contract_status` | V001 | `contracts.status` |
| `flow_status` | V002 | `sample_receipts.flow_status` |
| `receipt_result` | V002 | `sample_receipts.result` |
| `requirement_value_type` / `requirement_comparison` / `requirement_verification_status` / `requirement_judgment_mode` | V005 | `inspection_technical_requirements.*` |
| `calculation_algorithm_type` | V009 | `inspection_calculation_methods.algorithm_type` |
| `inspection_parameter_source_type` / `inspection_standard_status` / `qualification_level` / `inspection_standard_role` | V008 | 字典 4 表 + 2 张 role junction |

**未转换**：`audit_action`（V006 引入）。原因见 §6。

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
   └─ L4: vitest run                  ← sql.replay.test（fresh DB 重放 V001→V017）
   ↓ exit 0

4. [msw / react / vue / nextjs / springboot / aspnetcore]
   bash scripts/gen-shared.{sh,ts}
   固定 3 步：
   a) (cd ../shared && npm run emit:openapi)
   b) 本地 codegen：openapi-generator (java) / NSwag (C#) / orval (TS)
   c) 后端专属：cp shared/sql/migrations/V*.sql 到 db/migration/
                （含 cmp abort 防护；防 2026-08-26 V014/V015 撞号事故）
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

### 4.2 改一次 SQL → 6 仓同步

```
1. [shared] 加新文件 sql/migrations/V018__*.sql（只增不修）
   ↓ git commit + push

2. [shared] npm run build（DDL 不影响 openapi.yaml，但仍跑确保 L1/L3 不退化）
   ↓

3. [shared] python scripts/gate.py -p lab-management-system-shared
   L4: vitest run
   ├─ sql.replay.test.ts: DROP SCHEMA + CREATE + EXTENSION → 跑全部 V*.sql
   ├─ 断言 25 张表 + 1 个 enum（audit_action）齐全
   ├─ 断言 sample_receipts jsonb 列、FK cascade、V012 多租户 index 收敛
   └─ 通过 → exit 0
   ↓

4. [直接推到 dev DB（不走 6 仓中转）]
   node scripts/sync-db.mjs                    # 全量重建 lab_dev @ 100.79.128.25
   node scripts/sync-db.mjs --incremental      # 增量：tracking 表 __schema_migrations
   ↓

5. [后端 springboot / aspnetcore / nextjs-self]
   springboot: Flyway 自动跑（flyway.enabled=true；见 §5）
   aspnetcore: dotnet ef migrations 镜像
   nextjs:     node-pg-migrate up
   ↓

6. [前端] 无操作（前端不读 SQL，仅靠 codegen 客户端的 enum 字符串同步）
```

**关键检查点**：

- 禁止修改已落地 V 文件（Flyway 兼容语义）——改字段只能加新 V；
- `sync-db.mjs` 全量模式不 `DROP SCHEMA`——库非空即中止（防误覆盖）；
- 增量模式基于 `__schema_migrations` tracking 表（双下划线前缀，排列表首），cold-start 时若 tracking 空但库已有业务表，自动 baseline 把现有 V 全部标已应用；
- shared 仓禁 npm runtime 依赖，`pg` driver 从相邻 `lab-management-system-nextjs/node_modules/pg` 借（详见 §3.8）；
- L4 跳过条件：`PG_REPLAY_SKIP=1`（CI 默认跑；本地无 PG 可跳）。

### 4.3 同步矩阵汇总

| 操作 | shared | msw | react / vue / nextjs | springboot | aspnetcore |
|---|---|---|---|---|---|
| 改 TypeSpec | emit:openapi → openapi.yaml | 调 emit + 重启 handlers | 调 emit + orval codegen | 调 emit + openapi-generator | 调 emit + NSwag |
| 改 SQL | L4 replay + push V | 无操作（不读 SQL） | 无操作 | cp V → `db/migration/`（Flyway 自动） | cp V → `Migrations/` |
| 推 dev DB | sync-db.mjs 直推 | 无 | 无 | 重启 / mvn spring-boot:run | 启动 dotnet |
| Schema emit 验证（lab-springboot 专属） | — | — | drizzle-kit pull → schema.sql 比对 | spring-boot:run 后 JPA 反射 | — |

### 4.4 门禁链

```
python scripts/gate.py -p lab-management-system-shared
  ↓
L0 结构完整性（suite 拥有）
  ├─ 必需目录存在：tsp/、sql/migrations/、generated/openapi/、scripts/、tests/、.harness/stack.json
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
- L4 的 `sql.replay.test.ts` 是契约仓独有的「fresh replay 链」门禁——等价于后端的集成测试，但跑在 shared 仓本地 PG 上；
- `trace_cmd = ["npx", "--no", "vitest", "run"]` + `TRACE_MAP=1` 触发 fnReporter 产 `.state/trace.json`（与跨语言锚点 [ADR-0002](../../../docs/adr/0002-trace-json-as-cross-language-anchor-contract.md) 一致）。

---

## 5. 契约消费矩阵：6 个消费仓怎么读本仓

| 消费仓 | 读 openapi.yaml | 读 sql/migrations/*.sql | 同步脚本 | codegen 工具 |
|---|---|---|---|---|
| `lab-msw` | 调 emit 后由 handlers 手工对齐 fixture | 不读（fixture 用 in-memory JSON） | `gen-shared.ts` 调 emit + 重启 server | 无（手写 handler shape） |
| `lab-react` | 同上 + orval codegen | 不读 | `gen-shared.ts` 调 emit + orval | orval + axios |
| `lab-vue` | 同上 | 不读 | `gen-shared.ts` 调 emit + orval | orval + axios + Pinia |
| `lab-nextjs` | 同上（但 nextjs 还借 pg driver + drizzle-kit pull 给 schema emit infra） | 不直接读（schema emit infra 独立路径） | `gen-shared.ts` 调 emit + orval | orval + axios；drizzle-kit pull（schema 比对） |
| `lab-springboot` | 同上 + openapi-generator | `gen-shared.sh` cp 到 `src/main/resources/db/migration/`（Flyway 自动跑，flyway.enabled=true） | `gen-shared.sh` 调 emit + codegen + cp SQL（含 cmp abort） | openapi-generator-cli（java）+ Flyway |
| `lab-aspnetcore` | 同上 + NSwag | `gen-shared.sh` cp 到 `Migrations/` 旁 | `gen-shared.sh` 调 emit + NSwag run | NSwag（C#）+ EF Core Migrations 镜像 |

### 5.1 springboot 专属：Flyway 启用 + 永久分叉管理

springboot 是 lab 家族唯一**启用 Flyway**的后端（saas-springboot `flyway.enabled: false`）。`scripts/gen-shared.sh` 把 shared V 文件拷到 `src/main/resources/db/migration/`，含 `DIVERGED_VERSIONS` 白名单（V014 等）。

V014 永久分叉详细背景见 §6。

### 5.2 nextjs 专属：借 pg driver + drizzle-kit pull schema

`lab-management-system-nextjs` 不直接读 shared SQL（其 drizzle schema 与业务独立），但：

- **借 `pg` driver**：`shared/scripts/sync-db.mjs` 与 `shared/tests/sql.replay.test.ts` 都通过 `createRequire("../lab-management-system-nextjs/package.json")` 借 nextjs 仓的 `node_modules/pg`（shared 仓禁 runtime 依赖）；
- **schema emit infra**：`lab-management-system-nextjs/scripts/emit-schema.mjs` 用 `drizzle-kit pull` + `fix-pulled-schema.mjs` 把 lab-springboot 跑出来的 schema 拉成 `schema.sql`/`schema.dbml`/`schema.ts`（gitignored）供 emit-only 比对。

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

## 6. V014 永久分叉

### 6.1 背景

V014 是 lab 家族的**永久结构性分叉**——shared 仓的 V014 与 springboot 仓的 V014 内容不同，但都收敛到「12 个 PG enum → TEXT」的目标。命名：V014（共享版本号）但内容差异化。

| 链 | V014 内容 | 终态 |
|---|---|---|
| shared（fresh replay 链） | `ALTER TABLE inspection_calculation_rules ALTER COLUMN algorithm_type TYPE text + DROP TYPE`（表还叫 rules） | `inspection_calculation_rules.algorithm_type` TEXT |
| shared 后续 | V017 `RENAME inspection_calculation_rules TO inspection_calculation_methods` | `inspection_calculation_methods.algorithm_type` TEXT |
| springboot（演化链） | `ALTER TABLE inspection_calculation_methods ALTER COLUMN algorithm_type TYPE text`（表已叫 methods） | 同上 |

**两条链的终态 schema 等价**（emit-schema 实测逐字节相同），但走法不可互换。

### 6.2 验证记录

| 日期 | 事件 | 决策 |
|---|---|---|
| 2026-08-24 | shared V014 落地（e6a3975，演化版 ALTER methods） | **不可行**——fresh replay 链走到 V014 时表还叫 rules，必炸 `relation does not exist` |
| 2026-08-26 | shared V014 改回「旧版 ALTER rules」 + V017 条件式 rename | V014 定格为永久结构性分叉 |
| 2026-08-26 | emit-schema 实测 schema.sql 逐字节收敛 | 验证通过 |
| 2026-08-26 | commit c81c040 + tag v0.1.7-20260826 + push origin/master | 提交 + 推 |

**详细记录见 ``.state/session.json``**（`current_task` + `last_session_summary` + `done[]` + `next[]` + `dont[]`）。

### 6.3 与 springboot 的版本号地图

| 版本号 | shared 内容 | springboot 内容 | 关系 |
|---|---|---|---|
| V001-V013 | 主干 13 表 | 同 | 逐字节相同（自 V011 起的 backwire 已对齐） |
| V014 | 12 enum → TEXT（**ALTER rules**） | 12 enum → TEXT（**ALTER methods**） | **永久分叉**（结构差异 + 终态等价） |
| V015 | smoke_seed_dict（与 springboot 逐字节相同） | 同 | 共享 |
| V016 | 空号（springboot B3 早期用过；shared 跳过） | 已删 | 跳号 |
| V017 | rename rules → methods（条件式 `IF EXISTS`） | 同（与 shared 逐字节相同） | 共享 |

**关键约束**（见 `session.json` `dont[]`）：

- ❌ 不要把 V014 改成 springboot 演化版（ALTER methods）——fresh replay 链必炸；
- ❌ 不要动 V015/V017 内容——已与 springboot 逐字节对齐，改一个字节就重现 flyway checksum 撞号事故；
- ✅ V014 永久保留「ALTER rules + DROP TYPE」形态 + V017 条件式 rename 收尾。

### 6.4 open questions

[V017__rename_calculation_rules_to_methods.sql](../sql/migrations/V017__rename_calculation_rules_to_methods.sql) 注释段已写明「shared 仓的 V014/V015 与本仓分叉待收敛（见 session.json 待办）」——但当前决策是**保持分叉**而非收敛（因为 fresh replay 链必须从 V001 开始按顺序跑通）。

可选后续（`session.json` `next[]`）：在 `sql/migrations/README.md` 写一页「V014 永久分叉 + V016 空号 + V015/V017 一致」版本号地图防 3 个月后自己看不懂；或起草一篇本仓独立 ADR 记录决策背景（详见 §7）。

---

## 7. 决策索引

本仓暂未起草独立 ADR（`docs/adr/` 占位）。决策引用全部走父仓 ADR：

### 7.1 直接相关

| ADR | 主题 | 与本仓关系 |
|---|---|---|
| [ADR-0007](../../../docs/adr/0007-shared-sql-ssot.md) | shared 仓扩到双 SSOT | **本仓核心**：同时是 API 契约 + DB schema 真源；禁 runtime npm 依赖；ORM 只反射 |
| [ADR-0009](../../../docs/adr/0009-db-credentials-env.md) | DB 凭据走 env | `sync-db.mjs` 的 PG_* env 来源；deploy 自举 |

### 7.2 间接相关

| ADR | 主题 | 与本仓关系 |
|---|---|---|
| [ADR-0001](../../../docs/adr/0001-suite-owns-l0-and-l5.md) | suite 保留 L0/L5 | 本仓 stack.json 只声明 L1/L3/L4 |
| [ADR-0002](../../../docs/adr/0002-trace-json-as-cross-language-anchor-contract.md) | trace.json 跨语言锚点 | L4 trace_cmd 触发 fnReporter 产 `.state/trace.json` |
| [ADR-0003](../../../docs/adr/0003-function-tree-requires-human-approval.md) | 功能清单变更需人批 | BASE tree 改 F 必须 `/tree-change` 提案 |
| [ADR-0012](../../../docs/adr/0012-msw-as-http-server.md) | msw 升级为独立 HTTP 服务 | 决定本仓 emit 的 openapi.yaml 是 msw 仓 fixture 的唯一依据 |
| [ADR-0014](../../../docs/conventions/multi-repo-family.md#4-后端配置env-driven-单-urladr-0014) | env-driven 单 URL | 6 仓前端读 openapi.yaml 时走同一 baseURL 配置 |

### 7.3 待起草（next）

- 本仓 ADR：「V014 永久分叉」（2026-08-26 决策背景）；
- 本仓 ADR：「FrontendBindMeta / M98 镜像」（emit-only 锚点不被后端实现的语义）。

详见 ``.state/session.json`` `open_questions[]`。

---

## 8. 术语表

| 术语 | 含义 | 详细 |
|---|---|---|
| **双 SSOT** | shared 仓同时是 API + DB schema 真源 | ADR-0007；本仓 `tsp/` + `sql/migrations/` |
| **BASE tree** | 契约仓的功能清单（只到 F） | [docs/functions/function-tree.md](functions/function-tree.md) |
| **OpenAPI yaml** | TypeSpec emit 出来的 API 契约 | `generated/openapi/openapi.yaml` |
| **V 文件** | Flyway 风格 DDL 真源（`V<NNN>__<desc>.sql`） | [sql/migrations/](../sql/migrations/)；只增不修 |
| **fresh replay 链** | DROP SCHEMA + 顺序跑全部 V*.sql 的测试模式 | `tests/sql.replay.test.ts` |
| **V014 永久分叉** | shared 与 springboot 的 V014 内容不同但终态等价 | §6；`session.json` |
| **evolved chain** | springboot 仓的 DDL 演化版（表已叫 methods） | lab-springboot `db/migration/` |
| **emit-only** | TypeSpec 定义但后端不实现，只作 codegen 锚点 | `FrontendBindMeta` / `/_frontend-bind/snapshot` |
| **sync-db** | 跨仓 DB 直推工具（不走 gen-shared 中转） | [scripts/sync-db.mjs](../scripts/sync-db.mjs) |
| **借 pg driver** | shared 仓借 nextjs 仓的 `node_modules/pg`（禁 runtime 依赖） | `createRequire("../lab-management-system-nextjs/package.json")` |
| **tracking 表** | `__schema_migrations`（双下划线前缀） | 排列表首；Flyway 风格 |
| **omit-unreachable-types** | TypeSpec 编译选项：未引用类型不 emit | `tspconfig.yaml` |
| **stack.json** | 项目自描述（栈 + 门配置） | `.harness/stack.json`；项目只声明 L1-L4 |
| **DIVERGED_VERSIONS** | springboot 仓允许的「与 shared V 文件内容差异」白名单 | lab-springboot `scripts/gen-shared.sh` |
| **cmp abort** | gen-shared 拷 SQL 前的「目标 ≠ shared 且文件已存在则 abort」防护 | 2026-08-26 flyway 撞号事故根治 |

---

## 附录 A：与父仓 docs/ARCHITECTURE.md 的关系

| 父仓文档章节 | 本仓文档对应章节 | 关系 |
|---|---|---|
| [§1 套件全景](../../../docs/ARCHITECTURE.md#1-套件全景) | §1 | 父仓列 14 仓全貌；本仓只 zoom in 自己 |
| [§2.1 五种角色](../../../docs/ARCHITECTURE.md#21-五种角色) | §1 | 父仓「契约仓 = 1 仓/家族」；本仓细化双 SSOT 职责 |
| [§2.3 5 段式骨架](../../../docs/ARCHITECTURE.md#23-仓库矩阵14-个仓各自-5-段结构) | §2 | 父仓列出通用形态；本仓列裁剪后形态（无 src/） |
| [§3.1 双 SSOT](../../../docs/ARCHITECTURE.md#31-双-ssotapi-契约--db-schema) | §3 + §6 | 父仓给出双 SSOT 原则；本仓给具体落地（V001-V017 + 25 张表；saas 家族到 V018） |
| [§3.2 一份契约，三套 codegen](../../../docs/ARCHITECTURE.md#32-一份契约三套-codegen) | §5 | 父仓列 codegen 链总览；本仓列 6 仓逐个怎么读 |
| [§3.7 Function Tree 是跨端对齐索引](../../../docs/ARCHITECTURE.md#37-function-tree-是-跨端对齐的索引) | §3.7 | 父仓解释 BASE + 各仓镜像；本仓 BASE 只到 F |
| [§4.1 契约仓职责详解](../../../docs/ARCHITECTURE.md#41-契约仓shared-2) | §3 + §4 | 父仓给出契约仓通用职责；本仓列具体模块切分 |
| [§5.1 改一次契约 → 三端同步](../../../docs/ARCHITECTURE.md#51-改一次契约--三端同步codegen-链) | §4.1 | 父仓给三步流程；本仓给 shared 视角的完整链 |
| [§7 决策索引](../../../docs/ARCHITECTURE.md#7-决策索引) | §7 | 父仓列 12 份 ADR；本仓引用 + 标注本仓特有待起草 |

**本文档与父仓 ARCHITECTURE.md 的边界**：

- 父仓文档是 **suite 级** ——回答「14 仓怎么组织、3 端怎么同步、端口 + CORS 怎么对齐」；
- 本文档是 **shared 仓级** ——回答「本仓内部怎么组织、TypeSpec + SQL 怎么对齐、V014 分叉怎么落地」；
- 本文档**不重复**父仓已说明的端口 / CORS / env / multi-repo-family 等通用约定；
- 本文档**会 zoom in** 到本仓特有的话题（V014 永久分叉、V015/V017 收敛、M98 镜像、emit-openapi bootstrap）。

---

## 附录 B：相关约定 / 决策 / 文档

- 父仓架构总览：[`docs/ARCHITECTURE.md`](../../../docs/ARCHITECTURE.md)
- 父仓多仓家族约定：[`docs/conventions/multi-repo-family.md`](../../../docs/conventions/multi-repo-family.md)
- 父仓 submodule 操作：[`docs/conventions/submodule.md`](../../../docs/conventions/submodule.md)
- 父仓 12 份 ADR：[`docs/adr/`](../../../docs/adr/)
- 本仓入口：[`CLAUDE.md`](../CLAUDE.md)
- 本仓功能清单：[`docs/functions/function-tree.md`](functions/function-tree.md)
- 本仓 SQL 命名约定：[`sql/README.md`](../sql/README.md)
- 本仓跨会话状态：``.state/session.json``
- 父仓跨会话经验：`~/.claude/projects/.../memory/MEMORY.md`（非入仓）

## 附录 C：本仓典型陷阱

| 陷阱 | 后果 | 解法 |
|---|---|---|
| 手写 `generated/openapi/openapi.yaml` | L1 红 + L4 类型不一致 | 必须 `npm run build` → `emit:openapi` |
| 改已落地 V 文件 | Flyway checksum 撞号 + 历史库炸 | 加新 V00N+1；老文件不修 |
| shared V014 改成 ALTER methods | fresh replay 链走 V014 时表还叫 rules，必炸 | V014 永久保留 ALTER rules + V017 rename |
| 借不到 pg driver | sync-db.mjs FATAL exit 1 | dev 环境先在 nextjs 仓 `npm install`；运行时容器 Dockerfile COPY 全量 node_modules |
| 删除 `FrontendBindMeta` 锚点 | 8 schema 被 `omit-unreachable-types` 丢 | 锚点必须留作 emit-only |
| `package.json` `exports` 暴露语言路径（如 `./api-client`） | 违反 [CLAUDE.md](../CLAUDE.md) §2 | 仅暴露 `./openapi` yaml 路径 |
| 改 F 级但不先改 BASE tree | L5 红 + 6 仓 I 级无 BASE 引用 | 改 F 必须先 `/tree-change` |
| 启动 L4 时本地无 PG | `vitest` 跑挂在 `pgModule` null | 配 `PG_REPLAY_SKIP=1` 跳过；或启本地 PG |
| `sync-db.mjs` 默认模式打满库 | 库非空即 abort，但脚本不自动 `DROP SCHEMA` | 重建先手动 `DROP SCHEMA public CASCADE; CREATE SCHEMA public;` |
| `@discriminated("kind")` 字符串参数 | v1.15 是 object 参数，编译报错 | 写 `@discriminated`（无参）即可 |
| model 上挂方法 | TypeSpec 不允许 | 改 namespace 级 op 或纯数据 model + doc 注释 |
| namespace 下裸 op 声明 | 自动当 HTTP 路由撞 `duplicate-operation` | 套 `@route` 子 namespace |
