# REQ-2026-039 技术要求页判定挂链（role=JUDGMENT）过滤与假链清洗

| 项 | 值 |
|---|---|
| 提出人 | zcqiand |
| 提出日期 | 2026-11-16 |
| 优先级 | P1 |
| 状态 | 已上线（2026-11-16） |
| 关联功能 | M06.F06.I01（技术要求列表树过滤变更）/ M06.F01.I05-I07（挂链 role 语义消费）——无新增子项，无字段变更 |
| 关联 ADR | — |

## 1. 需求描述

技术要求页标准树混入检测方法标准（GB/T 1346-2024 等选中后「暂无数据」）。用户裁定
（2026-11-16）：技术要求页只出**判定依据**——项目↔标准挂链本就有 `role` 必填
（TESTING/JUDGMENT，M06.F01.I05），**复用既有 role 机制，不加 standard_kind 字段**
（2026-11-16 二裁）：技术要求页树按挂链 role=JUDGMENT 过滤，并清洗存量假 JUDGMENT 链
（方法标准误挂 JUDGMENT 17 条，见 §4——这是 1346 出现在技术要求页的直接原因）。

## 2. 澄清记录

| # | 问题 | 裁定 |
|---|---|---|
| 1 | 排除机制：按零行过滤 / 加 standard_kind 字段 / 只删一条？ | 初裁选 kind 字段；发现挂链已有 role 语义后**二裁：不加 kind**（2026-11-16）——role=JUDGMENT 挂链即「判定依据」语义真源，字段冗余。104 标准全量分类表随之退役（原 §3），仅留 17 条假链鉴定依据（方法=纯方法面标准，零限值面）。 |
| 2 | 树过滤按什么？ | **挂链 role=JUDGMENT**（复用 M06.F01.I05-I07 既有机制，零契约变更优先：links 列表端点已支持 `role` 过滤）。计算方法页维持现状（不过滤）。 |
| 3 | 假 JUDGMENT 链怎么清？ | method 标准的 JUDGMENT 链：有 TESTING 孪生链的**删 JUDGMENT 行**；无孪生的**翻转为 TESTING**。清单见 §4，人批后机械执行。 |
| 4 | 清洗后如何防复发？ | **三令（2026-11-16 三裁：用户令「标准条款入库时需维护项目↔标准 TESTING/JUDGMENT」）**：①导入管线挂链维护——`tech-req:import` 落库时对每个 (object, judgmentStandardCode) 补缺 JUDGMENT 链、`calc-method:import` 同理补 TESTING 链（append-only，三键已存在则不动）；②护栏升级为**真不变量**：判定行 ⇒ JUDGMENT 链存在（机器可断言，4 条历史欠账见 §5 补链清单，2 条版本错位例外挂账钉在锚内）；③快照锚（16 删 1 翻转后 JUDGMENT 集合形状）作第二道锚。 |
| 5 | 其他后端栈与 react/vue 镜像？ | 本批落地 **shared 种子洗链 + nextjs 过滤**；其余消费仓镜像挂账另批。本批零 API 契约变更（links role 过滤端点已在契约内）；若计划落地中发现需新增端点/参数，按硬约束 contract-test 同 commit 同步。 |

## 3. 设计依据与假链鉴定口径

**method/verdict 解耦原则（用户 2026-11-16 提供方法论）**：method=「怎么做」（操作步骤/
仪器/计算公式，输出客观测量值），verdict=「算不算合格」（阈值/允许误差/等级划分，输出
定性结论）。两者多对多解耦（同一判定标准可配多种检测方法，反之亦然）、独立版本升级，
数据流严格单向：原始采样数据 →(执行 method)→ 检测结果 →(比对 verdict)→ 判定结论。

落到本系统：**role=挂链（关系）的属性，不是标准（实体）的属性**——检测项目↔标准挂链
带 TESTING/JUDGMENT role（M06.F01.I05），同一标准对不同项目可扮演不同角色；calc 管线=
method 面，tech-req 管线=verdict 面；运行时录入值经 calc 得结果、比对 verified+automatic
技术要求行出判定（DynamicFormRenderer，与上述单向流同构）。这是二裁不加 standard_kind
标准级字段的方法论根据。

假链鉴定口径：「方法标准」=纯方法面标准（检验方法/试验方法/测定方法/试验规程，无限值
验收面），基于标准名称+家族导入史（原 104 行分类草案在 `_work/standard-kind-draft.md`，
过程件留档不随本 REQ 入库）。**§4 清洗清单 + §5 补链清单是本 REQ 唯二人批数据面。**

「方法标准」=纯方法面标准（检验方法/试验方法/测定方法/试验规程，无限值验收面）。鉴定
基于标准名称+家族导入史（原 104 行分类草案在 `_work/standard-kind-draft.md`，过程件留档，
不随本 REQ 入库）。**清洗清单 §4 是本 REQ 唯一人批数据面。**

## 4. 假 JUDGMENT 链清洗清单（17 条，人批件）

| object | standard | 名称 | 处置 |
|---|---|---|---|
| OBJ-SP01-P1 | GB/T 1346-2024 | 水泥标准稠度用水量、凝结时间、安定性检验方法 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P1 | GB/T 17671-2021 | 水泥胶砂强度检验方法(ISO法) | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P1 | JTG 3420-2020 | 公路工程水泥及水泥混凝土试验规程 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P2 | GB/T 228.1-2021 | 金属材料 拉伸试验 第1部分：室温试验方法 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P4 | GB/T 10294-2008 | 绝热材料稳态热阻及有关特性的测定 防护热板法 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P4 | GB/T 11969-2020 | 蒸压加气混凝土性能试验方法 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P5 | GBJ 82-85 | 普通混凝土长期性能和耐久性能试验方法 | 翻转为 TESTING（无 TESTING 孪生链） |
| OBJ-SP01-P5 | GB/T 50082-2024 | 混凝土长期性能和耐久性能试验方法标准 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P5 | JTG 3420-2020 | 公路工程水泥及水泥混凝土试验规程 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P5 | SL/T 352-2020 | 水工混凝土试验规程 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P7 | JTG 3432-2024 | 公路工程集料试验规程 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P8 | JGJ/T 70-2009 | 建筑砂浆基本性能试验方法标准 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P8 | SL/T 352-2020 | 水工混凝土试验规程 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P9 | GB/T 50123-2019 | 土工试验方法标准 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP01-P9 | JTG 3441-2024 | 公路工程无机结合料稳定材料试验规程 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP02-P2 | GB/T 228.1-2021 | 金属材料 拉伸试验 第1部分：室温试验方法 | 删 JUDGMENT 行（TESTING 链已在） |
| OBJ-SP07-P11 | GB/T 228.1-2021 | 金属材料 拉伸试验 第1部分：室温试验方法 | 删 JUDGMENT 行（TESTING 链已在） |

## 5. 判定行缺链补链清单（管线维护规则回溯适用，人批件）

现行种子 4 对判定行缺 JUDGMENT 链（管线不维护挂链的历史欠账）：

| object | standard | 处置 | 说明 |
|---|---|---|---|
| OBJ-SP01-P1 | GB/T 200-2025 | **补 JUDGMENT 链** | 码面与字典一致，随本批补 |
| OBJ-SP01-P2 | GB/T 20065-2016 | **补 JUDGMENT 链** | 码面与字典一致，随本批补 |
| OBJ-SP01-P3-细骨料 | JGJ 52 | 挂账例外（版本错位） | 行引用 `JGJ 52`，字典只有 `JGJ 52-2006`——IMPORTED-ONLY 疑点族，版本归一另批，锚内显式例外 |
| OBJ-SP01-P5 | GB/T 50082-2009 | 挂账例外（版本错位） | 行引用 `GB/T 50082-2009`，字典只有 `GB/T 50082-2024`——同上 |

不变量锚：判定行 (obj,std) 对 ⊆ JUDGMENT 链 ∪ 上表 2 条显式例外。

## 6. 任务拆解

1. **T-1** 人批本 REQ（清洗清单 §4 + 补链清单 §5）→ 状态「开发中」转正。
2. **T-2** shared：inspection_object_standards.json 洗 §4 的 17 条假链（16 删 1 翻转）+
   补 §5 的 2 条 JUDGMENT 链 + 护栏测试三件（判定行⇒JUDGMENT 不变量含 2 显式例外 /
   快照集合形状锚 / GBJ 82-85 翻转行恰 1 条 TESTING）先红后绿。
3. **T-3** nextjs：技术要求页树按 role=JUDGMENT 过滤（links role 过滤端点已在契约，
   零契约变更）；计算方法页不变；组件测试先红后绿。
4. **T-4** 导入管线挂链维护：`scripts/tech-req-pipeline.ts` --write 后对每个
   (object, judgmentStandardCode) 补缺 JUDGMENT 链；`scripts/calc-method-import.ts`
   同理补 TESTING 链；append-only 三键去重；单测先红后绿（补链/幂等/零契约变更）。
5. **T-5** seed:db --reset 重浇 + 探针（技术要求页标准集合=JUDGMENT 链标准，GB/T 1346-2024
   等五代表不出现，TB 10424/TB∕T 3275/GB/T 200-2025 出现）+ 双门 gate + CHANGELOG/
   HISTORY + 镜像仓挂账登记。

## 7. 验收标准

- 清洗清单 §4 经人批（本 REQ 状态转「开发中」转正即批）。
- 技术要求页树只显 JUDGMENT 挂链标准；GB/T 1346-2024 选中路径消失；计算方法页不受影响。
- 护栏绿：判定行⇒JUDGMENT 链不变量（§5 两条版本错位显式例外钉锚）+ 快照集合形状锚。
- 管线挂链维护生效：tech-req/calc-method 导入落库自动补缺挂链（append-only 幂等，单测覆盖）。
- 零 API 契约变更（若破此承诺，contract-test 同 commit 补同步并在 REQ §2#5 记账）。
- gate L0-L5 绿（shared+nextjs）；react/vue 及其余后端栈镜像挂账登记在案（另批）。

## 8. 二轮清洗：TESTING 面镜像错挂（2026-11-16 五裁，人批件）

技术要求页修完（§4）后用户复检发现镜像面同病：**检测依据（TESTING）链上混入
判定/产品类标准**（截图 21：GB 175/GB/T 2015/GB/T 3183/GB/T 200/TB 10424/
TB∕T 3275/熟料等）。五裁=按提案执行：A 删/翻 + C 保留 + flag 保留 + D 深度正确化
（calc 行迁移到真方法标准，remark 留痕）。机械分类真源=`_work/standard-kind-draft.md`
（method 集合 40），白名单双链混合型={GB/T 50081-2019, JTG 3430-2020, JGJ 52-2006}。

### 8.1 A 组：删 TESTING（verdict 标准挂检测依据链，24+3=27 行）

机械规则（可复算）：TESTING 链上 standard ∉ method ∪ 白名单 ⇒ 删 TESTING 行。
其中 JUDGMENT 孪生在 → 直接删（24 行）；下列 3 行同规则但属 D 组锚定对象的外延
（175/1499.2 在其他 object 的无 calc 锚定 TESTING 链）一并删：GB 175-2023@OBJ-SP07-P9、
GB 1499.2-2024@OBJ-SP02-P2、GB 1499.2-2024@OBJ-SP07-P11（JUDGMENT 链不动）。
完整行清单由实现批按规则机械生成并落执行报告，本节规则即批件。

### 8.2 翻转：TESTING-only 的 verdict 标准（2 行）

| object | standard | 处置 |
|---|---|---|
| OBJ-SP01-P1 | GB/T 21372-2024（硅酸盐水泥熟料） | 翻转为 JUDGMENT（无 TESTING 孪生面需求，无 JUDGMENT 链） |
| OBJ-SP01-P7 | GB/T 51003-2014（矿物掺合料应用技术规范） | 翻转为 JUDGMENT（同上） |

（UPDATE role 字段原位翻转，非增删——与 §4 GBJ 82-85 翻转同款。）

### 8.3 C 组保留：GB/T 50081-2019、JTG 3430-2020 双链保留

方法名实锤 + 判定/计算行真实（机械推定误分类实为混合/方法标准）。草案分类修正记
混合型，TESTING+JUDGMENT 双链现状不动。

### 8.4 D 组：calc 行迁移到真方法标准（4 迁 1 删，深度正确化②）

| 参数 | object | 现锚（产品标准） | 迁移目标 | 依据 |
|---|---|---|---|---|
| IP-0001 凝结时间人工读数 | P1 | GB 175-2023 | **GB/T 1346-2024** | 凝结时间检验方法 |
| IP-0002 安定性人工判定（沸煮法） | P1 | GB 175-2023 | **GB/T 1346-2024** | 沸煮法安定性 |
| IP-0003 胶砂强度（175 行） | P1 | GB 175-2023 | **删行** | 同语义 GB/T 17671-2021 行已在（7.1 备注更全），迁移撞 (obj,param,std) dedupe 键且为信息子集 |
| IP-0153 重量偏差（每批 ≥10 根） | P2 | GB 1499.2-2024 | **GB/T 28900-2022** | 钢材试验方法（链接码以现行 `GB/T 28900-2022`@P2 为准） |
| IP-0577 颗粒级配累计筛余 | P3-细骨料 | GB/T 14684-2022 | **JGJ 52-2006** | 砂质量及检验方法（白名单混合型，TESTING 链已在；remark 内「14684 表 3」是级配区数据源引用，保留） |

迁移行 remark 追加「原锚 GB 175-2023，2026-11-16 二轮洗链迁移」式留痕；配套删 3 行
D 组 TESTING 链（GB 175-2023@P1、GB 1499.2-2024@P2、GB/T 14684-2022@P3-细骨料），
JUDGMENT 链不动。D 组零补链——28900@P2「漏挂」实为码错位假象（链接=补全行
`GB/T 28900`，实链=`GB/T 28900-2022`，同 JGJ 52 版本错位家族，挂账归一另批）。

### 8.5 flag 保留

JGJ 52（双链）、DB33/T 1095（仅判定）现状不动。TB∕T 3275（4 行）与 T/ZBTA 02
（1 行）不属保留 flag，随 8.1 删 TESTING。

### 8.6 护栏升级（不变量三道）

1. 判定行 ⇒ JUDGMENT 链（§5 例外，T1 已立，不动）。
2. **TESTING 链上零 verdict 标准**：每条 TESTING 链 standard ∈ method 集合 ∪
   白名单 {GB/T 50081-2019, JTG 3430-2020, JGJ 52-2006}（method 集合按草案机械生成
   内联钉锚）。
3. calc 行 testing_standard_code 同规则（∈ method ∪ 白名单）——calc 面防复发；
   行数锚 31→30 随批改（calc-method-formula.test.ts 用例 2b）。

### 8.7 终态计数（执行批机械复核后钉锚）

挂链行 219→**189**（30 删）；TESTING 115→**83**；JUDGMENT 104→**106**（2 翻转）；
calc 行 31→**30**（1 删）。T4 探针④随之改为「GB 175-2023@P1 仅 JUDGMENT 链」。
