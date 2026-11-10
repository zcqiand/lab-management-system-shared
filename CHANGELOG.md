# CHANGELOG — lab-management-system-shared

格式参照 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]
- chore(rename): 系统显示名统一（suite 全家族批）——「实验室管理系统」→「建筑工程实验室管理系统」；「身份平台」名称位（标题/品牌/包描述/UI 标签）→「SaaS 多租户多应用身份平台」，行文短称保留。同批兄弟仓同节奏提交。
 — 2026-11-09/10

### Changed — 钢筋力学四接口结构化表格种子 + ADR-0056 种子漂移回灌（2026-11-10 人裁「落这个批」）

- **四个钢筋力学接口 config 转结构化表格列**（yield/tensile + connection 两变体）：
  `columns: [{loads input}, {diameters input}, {strengths computed steel_tensile},
  {req static}]` + highlight 越限红显。阈值全部有 tech_req 种子背书不编数：
  IP-0086 屈服 ≥400 / IP-0087 抗拉 ≥540（GB 1499.2-2024 技术要求）。
  connection-tensile 断裂位置保留独立 select_series；version 1→2。
- **种子漂移收口（SSOT 纪律）**：发现 nextjs src/seeds 在 ADR-0056 回放时只改了
  消费仓没回灌本仓（variant 派发键 / 渗水情况 select_series / 抗压强度代表值
  label / 土工压实度 maxDryDensity 等字段细化，16/18 行语义领先）——本批以
  nextjs HEAD 语义为基准叠加四个结构化 config 回灌本仓 SSOT。消费仓镜像三处
  （nextjs src/seeds ↔ src/data/generated ↔ vendor/msw seeds）byte-identical。
- 消费仓镜像同步：lab-nextjs 渲染器扩展批同 commit 节奏（见其 CHANGELOG）。

### Changed — 动态表单 Schema/Data 解耦（ADR-0056，2026-11-10 人批 + 批中补充裁定）

**src/db/schema.ts（DB 唯一真源）**

- `inspection_param_interfaces`：**component_path 退役**（schema 驱动动态渲染是唯一
  渲染路径）；**is_official / sort_order 退役**（2026-11-10 批中追加裁定）；新增
  **version int default 1**（结构迭代）；`config` 语义升级为表单结构 schema
  （`{title?, fields[], computed[], params}`——fields=采集面 8 种字段类型；
  computed[].algorithm 与 ck_calc_algorithm_type 同域 7 值，计算逻辑归算法域；
  params=算法入参常数）。
- `test_records`：**requirement_code 退役**（批中补充裁定）；新增
  **data jsonb default '{}' notNull**（动态表单采集原值+计算产物）；requirement/
  result/verdict 保留为汇总快照列。
- `inspection_param_interface_links`：**config 退役**；新增
  **inspection_standard_code text**（绑定检测依据，可空=不限，FK set null，
  与 report_name_code 同款作用域语义）。

**drizzle/ + 库**

- 增量迁移 0001（纯 ADD version/data，两段式生成避开 drizzle-kit 交互式 rename
  询问）→ 0002（纯 DROP component_path/requirement_code）→ 0003（ADD
  links.inspection_standard_code）→ 0004（DROP is_official/sort_order/links.config）。
  lab_dev / lab_test 已 migrate，数据零动；**prod 未动**（随 ADR-0055 prod 窗口一并人批）。

**tsp/（API 契约）**

- `ParamInterface`：-componentPath/-isOfficial/-sortOrder，+version（响应必填）；
  Create/Update 请求同形（version 可选，服务端缺省 1）。
- `TestRecord`：-requirementCode，+data: Record<unknown>（响应必填，缺省 {}）；
  Create/Update 同形。
- `ParamInterfaceLink`：-config，+inspectionStandardCode?。
- 端点路径与状态码零变化；generated/openapi 已重编译。

**seeds**

- 18 个参数界面 config 全部 schema 化（ CementCompress/Flexural 带 gb17671 variant、
  抗渗 permeability_grade、级配 table 形 + 砂/石筛孔集入 params、焊接弯曲 3 试件、
  土工击实/压实度复合形状）；150 条 test_records 去 requirement_code；
  links 22 行去 config、加 inspection_standard_code: null。
- 三份镜像同步：nextjs src/seeds ↔ nextjs src/data/generated ↔ nextjs
  vendor/msw/src/seeds。

**决策记录**：suite `docs/adr/0056-lab-dynamic-form-schema-data-decoupling.md`。

### Changed — DB 六裁定落 SSOT + drizzle 全量 re-baseline（ADR-0055，2026-11-09 人批）

**src/db/schema.ts（DB 唯一真源）**

- 四小字典（brands/models/specs/grades）与技术要求（technical_requirements）
  **去 tenant_id**（全局共享；原「PK=code + tenant 唯一索引」自相矛盾 / tech_req
  PK 缺 tenant 跨租户必撞）。
- tech_req min/max：integer → **numeric(12,4)**。
- samples：model/specification/grade/brand **保持裸 TEXT 不挂 FK**（2026-11-09
  人裁翻案——字典表职责 = 值域校验 + UI 选项来源，校验在应用层；历史字典外值合法）。
  新增唯一索引 `idx_samples_tenant_code (tenant_id, sample_code)`。
- inspection_objects **直挂列 inspection_specialty_code 删除**——专项归属以
  junction 表 inspection_specialty_objects 为唯一真源（M:N；删前实测 111 对
  直挂与 junction 完全一致，零数据丢失）。
- 全库 created_at/updated_at：TEXT default '' → **timestamptz notNull defaultNow()**
  （mode:"string"）；业务时间字段（commission_date 等）仍 TEXT。
- 4 业务表 tenant_id **去 default ''**（notNull 无默认，身份必须显式，ADR-0019 同精神）。
- **12 个 ck_* CHECK 约束**（contracts.status / receipts.flow_status /
  standards.status / params.source_type / obj_params.qualification_level /
  rn_std.role / obj_std.role / tech_req value_type·comparison·judgment_mode·
  verification_status / calc.algorithm_type）——值域与 TypeSpec enum 一字不差
  （含 ≥/≤/= CJK 符号）；预检脚本证实全部种子值落域。
- receipts 快照字段（projectName→witnessPhone）加注释：接样时刻冻结，
  合同带出 → 接样单可覆盖，不随合同变更联动。

**drizzle/ + 库**

- drizzle/ 全删重出 `0000_target_ddl.sql`（TEXT→timestamptz 无 USING 形态 +
  禁手改 drizzle SQL → 全量 re-baseline，先例 2026-09-13 批）。
- lab_dev / lab_test（127.0.0.1:54321）已 rebaseline + 重灌种子；
  备份 `_work/lab_dev-backup-20261109.json` / `_work/lab_test-backup-20261109.json`。
  **prod（100.79.128.25）未动**——迁移窗口需另行人批（rebaseline 脚本
  NODE_ENV=production + PG_REBASELINE_ALLOW=1 护栏在）。
- 种子确定性变换（过程件 `_work/seed-transform.mjs`）：空串时间戳 →
  `2026-01-01T00:00:00Z`（8706 处）；五表去 tenant_id（670 行）；objects 去
  直挂键（111 行）。samples 字典字段原值保留（#4 翻案后 FK 不存在，'' 与
  字典外值均合法）。

**决策记录**：suite `docs/adr/0055-lab-db-six-rulings-rebaseline.md`。

### 兄弟仓同步清单（「同步其他仓」照单回放，不依赖会话记忆）

全部 lab 消费仓（aspnetcore/springboot/rails/fastapi/laravel/go/ktor/django/swift/
flutter/react/vue/angular/miniprogram/android/harmonyos/react-native/e2e/contract-test）：

1. **重 pull DB schema**（bash scripts/pull-schema.sh 或各仓同款链）——表结构变了
   （字典/tech_req 无 tenant 列、objects 无直挂列、时间列 timestamptz、
   tech_req min/max numeric）。
2. **修自家租户查询**：凡对 brands/models/specs/grades/technical_requirements
   按 tenant_id 过滤/写入的代码——列已不存在，改全局查询（认证 401 边界不变）。
3. **objects 专项过滤**：直挂列查询改走 inspection_specialty_objects junction。
4. **时间列写入**：任何 `created_at/updated_at` 空串兜底（`?? ""`）必须退役——
   缺省落 DB now() 或应用层 toISOString()；'' 现在是非法输入（PG 22007/22008）。
5. **inline 种子/测试 fixture**：contracts/receipts 等 INSERT 显式带 tenant_id
   （default '' 已废除）；时间字面量改 ISO 8601。
6. **contract-test 仓**：涉及 catalog/objects/tech-req 的断言按新语义重放
   （全局集合、junction 过滤）；tenant 过滤断言退役。
7. 回放顺序建议：shared（本批）→ nextjs（已完成，见下）→ 其余仓按家族批次排队；
   每仓回放后跑自家 gate，exit code 唯一真相。

## [0.1.7] — 2026-08-27

- 初始化台账：契约仓：TypeSpec 真源，产出 OpenAPI 3.1 + SQL DDL。历史变更见 git log 与 `.state/session.json`。
