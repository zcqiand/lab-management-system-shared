# CHANGELOG — lab-management-system-shared

格式参照 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]
- fix(seeds): GB/T 200 种子升版 2017→2025 回放（lab-nextjs 同批，常设令第二例，
  语料 2025 版代替 2017）——standards 行 + 接样单 7 处 + 关联表，四镜像 byte-equal。
- fix(seeds): GB/T 1345 种子升版 2005→2026 回放（lab-nextjs 同批，2026-11-13 人裁
  「2026 有效、2005 过期，后续标准版本漂移都按语料现行版升种」）——
  inspection_standards 行 code/version 升 2026 + 接样单 testing_basis 14 处 +
  标准参数/对象标准/报告名标准关联表，四镜像 byte-equal。
- fix(seeds): 计算方法公式面 kN 语境同步（bb57dfc，lab-nextjs 批D 裁定① 随批回放）——
  IP-0086/0087 四行 formula `ROUND_HALF_EVEN(Fm / ...)` → `ROUND_HALF_EVEN(Fm * 1000 / ...)`，
  与 nextjs src/seeds、vendor/msw、data/generated 四镜像 byte-equal；引擎/REGISTRY 不动
  （Fm 键语义 N→kN，公式内 ×1000 补齐）。真值回放锚 358.2/Φ32→445 等实测锚过门。
- fix(seeds): 拆卡旧占位链清理 SSOT 侧——IP-0560/IP-0097 同款 link 遮蔽（2026-11-12
  用户裁定「同批清理」，与 IP-0152 旧链退役同模式）：2026-11-10 拆卡波只加新卡链
  没删旧占位链，同层先登记者胜出，旧链抢走解析——IP-0560 超强比旧链
  →rebar-mech-yield-ratio（2026-01-01 错绑强屈比卡）遮蔽 →rebar-mech-super-ratio；
  IP-0097 最大力总延伸率旧链 →rebar-mech-elongation（错绑断后伸长率卡）遮蔽
  →rebar-mech-agt。inspection_param_interface_links.json 删 2 行（26→24；IP-0559
  强屈比链不动）。消费仓实现详单（真种子回归锚三支、generated/vendor camel 镜像
  同步）见 nextjs CHANGELOG 同日条。
- fix(seeds): 焊接抗拉强度修约至 1 MPa 整数位 SSOT 侧（2026-11-12 用户裁定：
  JGJ/T 27-2014 §3 引 GB/T 228.1，GB/T 8170 四舍六入五成双）——纯消费仓代码批，
  shared 侧无种子面改动，仅记事。消费仓实现详单（tensileStrength/meanOfSpecimen/
  weldingTensile 均值转整数、DOM 五钉）见 nextjs CHANGELOG 同条。
- fix(seeds): 延伸率修约分档（2026-11-12 用户裁定：GB/T 1499.2 产品标准优先于
  GB/T 228.1 基底）SSOT 侧：inspection_calculation_methods.json IP-0150 断后
  伸长率 rounding_rule 修约到 1%→**0.5%**（旧值与速查表不符一并纠）、IP-0151
  最大力总延伸率 修约到 0.5%→**0.1%**（抗震钢筋习惯）。消费仓实现详单
  （elongationBy rounder 分档派发 / roundHalf 新导出 / 红-first 两用例）见
  nextjs CHANGELOG 同日条。
- fix(seeds): 强度修约收口至整数位（2026-11-12 用户裁定「修约至 1 MPa（保留 0 位
  小数）」SSOT 侧，第二批）：rebar-mech-* steel_tensile **列级** computed 补
  `"decimals": 0`（8 处；顶层 mean 9 处 `showDisplay:false` 不渲染不动），与消费仓
  三镜像同 commit 节奏 byte-equal。消费仓实现详单（显示层 `?? 1` 兜底暴露、
  steelTensile 均值转整数、批A 模板同步、测试钉值更新）见 nextjs CHANGELOG 同日条。
- chore(seeds): SAMPLE-FM-0017（YP-2026-F0017-01）牌号 HRB400→HRB400E、规格
  Φ25→Φ32（2026-11-12 用户裁定 SSOT 侧）：种子与消费仓 src/seeds byte-equal
  同改（含样品名勘误——旧值「钢筋机械连接接头试样」与报告 RN-102-1 钢筋力学
  性能不符，纠为「钢筋力学性能试样」）；消费仓 fixtures 派生面（flow-matrix
  n===17 单点覆写）、.next 陈旧缓存复发与 live PUT 详单见其 CHANGELOG 同日条。
- chore(seeds): RECEIPT-FM-0017 retest_mode double→none（2026-11-11 用户裁定
  「WS-2026-F0017 数据改成非复验报告」SSOT 侧）：live lab_dev 已 PUT 落库；
  种子双侧 byte-equal 同改，防下次 seed:db 翻回。消费仓详单见其 CHANGELOG 同日条。
- chore(seeds): inspection_calculation_methods.json shared 侧回放补欠账——批1
  （nextjs 25de2d4，2026-11-11 人审定稿表达式）只同步了消费仓三镜像、漏了
  shared SSOT 侧，seeds-parity 门红（本仓 L4）；字节拷贝恢复双写约定不变式，
  内容零改动（已人审定稿，非新内容）。另：批1 自己的延批待办「generated 镜像
  五行漂移」仍归批1 收口。
- fix(seeds): IP-0152 旧占位链退役——反向弯曲界面修复（2026-11-11 用户报障
  「反向弯曲界面没有改过来」SSOT 侧）：RN-102-1 下 IP-0152 同时挂旧占位链
  （→rebar-mech-tensile，2026-01-01 时代占位，把反向弯曲错绑抗拉表格卡）与新
  模板卡链（→rebar-reverse-bend），消费仓 resolveInterfaceByParam 同层先登记者
  胜出 → 旧链排前遮蔽新卡。四镜像删链（26 行；消费仓实现详单与真种子回归锚
  三支见 nextjs CHANGELOG 同日条）。
- feat(seeds): 弯曲性能/反向弯曲/重量偏差三卡 + IP-0153 verified min/max 回填
  （2026-11-11 用户裁定「反向弯曲、重量偏差（%）、弯曲性能按报告模板建卡」SSOT 侧）：
  ① inspection_param_interfaces 24→27——rebar-bend（弯心直径+弯曲结果 select
  无裂纹/裂纹，2 行，rebar_bend 顶层 computed showDisplay:false）、
  rebar-reverse-bend（同列 1 行）、rebar-weight-deviation（试样长度×5+实际总重+
  理论重量+req_select+computed 检测结果列，weight_deviation 算法 dev=(W−ρΣL)/(ρΣL)
  ×100 保留 1 位）；schema 渲染层新列模式 `select`（options 由种子携带）由消费仓
  渲染器同批支持。② inspection_param_interface_links 24→27——三参数（IP-0155/
  IP-0152/IP-0153）→ 三卡 scoped RN-102-1（钢筋力学报告；IP-0155 全局
  IP-0155→rebar-welding-bend 链保留供其他报告）。③
  inspection_technical_requirements IP-0153 verified Φ6~12 行 min/max 回填 ±5.5
  （remark 已有记载；ADR-0055 numeric(12,4) 落地后 integer 置 null 的候选 V014
  就此收口；reviewed ±4.5/±3.5 行不动——T-2b 人批前不入下拉/判定）。
  camel 镜像（消费仓 vendor 27/27/238 与 generated 27/28/159）同 commit 节奏同步，
  verified 行 min/max 消费仓镜像本就为 ±5.5 无需改；消费仓实现详单（rebar_bend/
  weight_deviation 算法、单项评定全线退役、录入卡排序）见 nextjs CHANGELOG 同日条。
- feat(seeds): 机械性能表格卡补顶层 computed（2026-11-11 用户报障「保存了但没自动
  评定」修复的 SSOT 侧）：rebar-mech-* 12 卡 config 只有列级 computed，顶层无
  computed → 消费仓 schema.computed 派发从不发生 → verdict 恒不产出。补
  yield/tensile/连接件×2 及 4 复验变体=steel_tensile；elongation/agt=elongation
  (+variant agt)；强屈比/超强比=yield_ratio/super_ratio。追加（同日）：顶层 computed
  增 `showDisplay:false`（不要均值行，只要右上角自动评定——2026-11-11 用户裁定）。
  二次追加（同日）：12 卡 table 字段增 `showLabel:false`（不渲染表题小标题——
  卡头已命名，「屈服强度测定」这类表题行重复，用户裁定去除；消费仓渲染器同批
  支持）。三镜像（shared SSOT / nextjs src byte-copy / vendor+generated camel）
  同 commit 节奏；
  消费仓修复详单见 nextjs CHANGELOG 同日条。
- feat(seeds): REQ-2026-038 T-2 人核通过 → 70 行转 reviewed 并入种子
  （32→102 行；+70 行带 clause/source_page/source_hash 溯源，GB 1499.2-2024
  表4/表6/表7 全量切片，verification_status=reviewed 待人批转 verified）。
  消费仓镜像同步：lab-nextjs 同 commit 节奏（vendor 238 / src 102，byte-copy
  本仓），见其 CHANGELOG。
- fix(seeds): 钢筋力学技术要求剥 spec/grade（2026-11-11 人裁定：力学性能只跟牌号，
  规格与等级必须空；grade 对 GB 1499.2 全参数清空，spec 仅弯曲/重量类保留——表7/表4
  直径段是要求本身）。根因与证据链落 `docs/requirements/REQ-2026-038` §6。同 commit
  兄弟仓（react/vue/aspnetcore/springboot/rails/fastapi/kotlin/laravel/go 等 20 仓）
  各自 seeds 镜像同节奏回放——**回放清单见 lab-nextjs CHANGELOG 同批条目**。
- chore(doc): REQ-2026-038 补 §6 根因记录（git 考古证据链 + 三层真因 + T-5 维度依赖
  声明机器不变式提案）。
- chore(rename): 系统显示名统一（suite 全家族批）——「实验室管理系统」→「建筑工程实验室管理系统」；「身份平台」名称位（标题/品牌/包描述/UI 标签）→「SaaS 多租户多应用身份平台」，行文短称保留。同批兄弟仓同节奏提交。

### Changed — 钢筋四接口结构化拆分 + M06.F09 树注册（2026-11-10 人裁第二波）

- **断后伸长率/最大力总伸长率拆两卡**：各自结构化表格（原始标距｜断后标距
  input → 伸长率 computed decimals 1｜标准要求 req_select），算法 elongation
  扩标距口径（gaugeLengths/fractureLengths → (Lu-L0)/L0×100，手输百分比回退）；
  最大力总伸长率 = algorithm elongation + variant agt。
- **强屈比/超强比拆两卡**：比值测定表 computed 列跨记录预填（crossRecord 联立，
  specimenCount=rows）；强屈比 yield_ratio decimals 2；超强比 = algorithm
  auto_calc_ratio + variant super_ratio（只吃 实测屈服/标准屈服）。
- **种子**：rebar-mech-elongation 换 elongationTable；新增 rebar-mech-agt /
  rebar-mech-super-ratio 两接口 + IP-0097/IP-0560 两条 link（24/24）。
- **树/契约**：M06.F09 功能树注册（I01-I07，人批）+ tsp 挂锚 + GET /links
  ADR-0034 §3 豁免；contract-test 同 commit 补 report-name-interfaces 读/写
  两测试文件（SSOT 覆盖 127/127）。
- 消费仓镜像同步：lab-nextjs 同 commit 节奏（渲染器/算法/页面/种子三镜像），
  见其 CHANGELOG。
- **种子格式收口（seeds-parity 追平 2fdc56e 先例）**：本批种子直写为展开形，
  parity 测（sha256 字节等）× nextjs prettier 90 列规范形双夹击红——shared seeds
  须按 nextjs .prettierrc（printWidth 90）canonical 形格式化后 byte-copy 消费仓，
  shared 无 prettier 门（L1=tsp compile）不会自己纠正。

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
