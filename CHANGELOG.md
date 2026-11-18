# CHANGELOG — lab-management-system-shared

格式参照 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]

- feat(seeds): **批CE2 水泥方法标批——GB/T 8074-2008 比表面积 calc 单行导入（2026-11-18，覆盖推进第 4 批）**——
  inspection_calculation_methods.json +1（35 行）：OBJ-SP01-P1 × IP-0548 ×
  GB/T 8074-2008，algorithm_type=manual，rounding=保留至 10 cm²/g，remark
  勃氏透气对比式族 LaTeX（式(2)-(7) $S=S_s\dfrac{\sqrt{T}}{\sqrt{T_s}}$ /
  η 粘度修正 / 空隙率因子 / 密度比 + 式(1) m=ρV(1-ε) + 7.3 空隙率
  PⅠ/PⅡ 0.500±0.005、其他 0.530±0.005 + 8.4.1 修约面）。挂链零新增
  （P1×8074 TESTING 先前已在；三标全在 method 40 集，白名单不动）。
  范围定性：GB/T 208 密度 / 2419 流动度参数码不在 P1 链→立码候选挂账
  36/37（账 29 族）。抽端转义纪律落地首例（Write 工具+chr(92) 构造，
  批R3 heredoc 指纹应用，一次干净）。
  seed:db 重浇 + seed:check clean + DB 探针干净 + 种子字节复核
  （TAB: False / `\sqrt` 字面在）。兄弟仓同步清单：nextjs（守卫计数随批改
  同批提交）；react/vue 零改动（种子唯一源无镜像回写）。

- feat(seeds): **批R3 钢筋方法标批——GB 13788-2024 重量偏差 calc 单行导入（2026-11-18，覆盖推进第 3 批）**——
  inspection_calculation_methods.json +1（34 行）：OBJ-SP01-P2 × IP-0153 ×
  GB 13788-2024，algorithm_type=manual，rounding=按 YB/T 081 修约，remark
  LaTeX 式(3)（$W=\dfrac{M-(L\times m)}{L\times m}\times100\%$，符号 M/L/m
  全按 7.5 条实文）+ 表4 取样挂面。挂链 +1：P2×GB 13788-2024 TESTING
  （JUDGMENT 链先前已在，真双链成形）。范围定性（七标准语料实测）：232/2651/
  2653 零导面；21839 公式面归账 1 公式转录批族；42901 滑移行语义重复不导（账 34）；
  JGJ/T 27 立码候选（账 35）；13788 表2 矩阵 OCR 塌缩等 PDF（账 33 RA-13788-1）。
  挂账总账 32→35。抽端转义事故修复在案（bash heredoc 吞反斜杠→TAB 进种子，
  Edit 工具修复+重浇，指纹入 HISTORY 教训段候选）。
  seed:db 重浇 + seed:check clean + DB 探针（remark 无 TAB、`\times` 字面在、
  J/T 双链齐）。兄弟仓同步清单：nextjs（守卫随批改同批提交）；react/vue 零改动
  （种子唯一源无镜像回写）。

- feat(seeds): **计算方法备注批——33 行备注换标准计算方法说明（含公式，md+LaTeX；2026-11-18 用户需求「备注里面写md计算方法说明（包括公式）」）**——
  inspection_calculation_methods.json 全 33 行 remark 逐行转写（updated_at
  2026-11-18）：公式行 LaTeX 化（GB/T 176 式 27/30/31/42-44/66、50081 抗压/
  抗折/劈裂/弹模、17671 式 1/2、1345 式 1、28900 式 10、JGJ 52 筛余、JTG
  3430 压实度等），manual 行换标准判读/判定方法说明（1346 凝结时间读数节
  奏/雷氏夹增值判定、28900 弯曲人工判定、50082 逐级加压+P=10H−1）；剔除
  规则/尺寸换算系数/修约全按条款实文。**公式转录坑在案**：语料公式块 OCR
  碎化（分式压平/下标丢失/LOI→LOD），纯机器转录必错——本批=语料锚定+
  人工转写+差异表人批（calc-remark-merge.py dry-run 默认、33/33 命中、
  calc-remark-diff-report.md 人批 2026-11-18 用户批「批准，照表写入」）。
  JTG 3430-2020 三行语料外（语料 0 块），人工转写并注记「语料外人工转写」
  待语料补齐另批校正。消费面：nextjs MarkdownRemark 已在（本批前收官），
  列表列/弹窗预览直接渲染公式。兄弟仓同步清单：nextjs（同批收尾提交）；
  react/vue/angular/RN 镜像批挂账不变。
  seed:db 重浇 + seed:check clean（dedupe 2 variant 行=PK 粒度常态）+
  DB 探针 27/31 行带 $ 公式。

- fix(seeds): **表格化批子批 3——15 张 series 卡换表格形 version+1（对照表人批 2026-11-18，用户原话「标准导入时尽量用表格界面」）**——
  inspection_param_interfaces.json 15 行 config 换表格形（version+1、
  updated_at 2026-11-18）：焊接抗拉/弯曲（=模板输出逐字节深等）、接头
  agt/residual（simple_avg 均值）、水泥抗压/抗折（=模板输出，rows 6/3 +
  area/span/width 协议常数）、混凝土/砂浆抗压（rows 3 + area 22500/5000）、
  抗渗（permTable rows 6 渗水压力/渗水情况 select）、劈裂抗拉（splitTable
  rows 3 manual 面）、土工击实（compactionTable rows 5）、压实度环刀/灌砂
  （maxDryDensity 留表外 number + degreeTable rows 6 文本量 input_text 列
  + showMaxDensityColumn params）、细度（finenessTable rows 2）、安定性
  （soundnessTable rows 2 无 computed）。**config.computed 全部原样保留**
  （引擎/verdict/record JSON 形状不变），列键=旧 series 键消费面零波及。
  空 params {} 一律删键（parseFormSchema 缺省 {}）。模板消费 4 行（焊接×2
  +水泥×2）与 card-templates 模板输出逐字节深等（护栏测试锚）。
  _work/tableize-15-interfaces.py 过程件留档（确定性变换防长 CJK Write 退化）。
  兄弟仓同步清单：nextjs（表格形模板/resolver/测试同批收官）；react/vue
  镜像批挂账不变（镜像 renderer 尚不支持 input_text/列 defaultValue）；
  angular 生成快照归 angular 镜像批。

- fix(seeds): **参数界面标题与内容一致化三行（2026-11-18 用户裁定）**——
  inspection_param_interfaces.json 三行换版：①rebar-mech-elongation v2→3
  名「断后伸长率+最大力总伸长率」→「断后伸长率」（Agt 半 2026-11-10 已拆分
  至 rebar-mech-agt，标题剔「+」陈尾，描述同步）；②rebar-mech-yield-ratio
  v2→3 名「强屈比+超强比」→「强屈比」（超强比半已拆至 rebar-mech-super-ratio，
  描述同步）；③rebar-mech-connection-tensile v3→4 断裂位置由表外独立
  select_series 并入表格 select 列（用户裁定「断裂位置作为表格列放在上面的
  表格不是正好」；mode:select+列级 options=2026-11-11 弯曲卡先例；键
  fractureLocations/存储形状 string[] 不变——algorithms/rebar-mechanics/
  报表模板 srecord 源全按键读，消费面零改动；模板 steel_tensile 屈服卡共用
  面不动，本行维持超模板手维护姿态）。护栏面：card-templates/assembler
  深等的是 config 非 name——改名零波及。seed:db 重浇 + seed:check clean。
  兄弟仓同步清单：nextjs（预览测试标题断言同批改）；angular 生成快照
  inspection-param-interface.json 仍持陈名——归 angular 镜像批（挂账）。

- feat(contracts): **specimen_count 归属迁移 Phase 3——calc 表删列收官**（tsp→
  openapi→DB 全链摘除）——契约：tsp/models/calculation-method.tsp 三 model
  （CalculationMethod/Create/Update）删 specimenCount，openapi.yaml 再生（0 命中）；
  DB：src/db/schema.ts 列删 + drizzle/0011_glossy_mandroid.sql（单条
  `DROP COLUMN IF EXISTS`，lab_dev+lab_test 均应用，列+not_null CHECK 双消）；
  种子：inspection_calculation_methods.json 33 行全摘键（diff 干净 33 删），
  inspection_param_interfaces.json remark 措辞同步（「组数由界面 schema rows 驱动」）；
  文档：docs/functions/function-tree.md M06.F05.I03 删「specimenCount 默认 1」。
  管线宿主侧（nextjs 同批）：A 档源改语料锚直读（assembler rowsOrThrow/countOrThrow
  fail-fast、6 锚 target 改 param_interface.count、calc-method-gate sanity 面退役
  12 键键集失配 throw）、calc 页 UI 摘除试件数量列与表单字段。contract-test 同步：
  全量断言审计零命中（specimen_count 无任何断言引用）——本批无测试面改动，按
  CLAUDE.md §2 记录清偿。seed:db 重浇 26 表 + seed:check clean；DB 探针 31 行
  （33−2 dedupe 常态）12 列无 specimen_count。兄弟仓同步清单：react/vue——
  SDK 契约删列再生 + inspection-capability 同款 UI 适配，随镜像批（徽标+列修复+
  Phase 2 回退链回放）一并回放，本批未动。

- feat(seeds): **specimen_count 归属迁移 Phase 1——12 参数补卡批**（2026-11-17
  人裁「按迁移序走：先补 interface count 面」）——审计定性：calc 表
  specimen_count 已成陈旧副本（DIFF 参数 live 用 interface 值；钢筋族 table+rows
  早已配齐），真缺口 = 14 参数无挂卡（无卡不在录入流）。本批 12 interface +
  12 link append（IP-0003 胶砂强度 / IP-0056 抗折强度 与 cement-compress/
  flexural 全量 links 对账：cement-compress 挂 IP-0556/0558、cement-flexural
  挂 IP-0555/0557，IP-0003/IP-0056 疑似新旧重复，排除待人裁）。卡形状：单值
  number 卡（凝结时间初凝/终凝、氯离子/碱/SO₃/烧失量、弹性模量、最优含水率）+
  series 卡（安定性 ×2、细度 ×2+simple_avg、接头延伸率/残余变形 ×3+simple_avg、
  劈裂 ×3）。护栏测试 tests/seeds/param-interface-link-coverage.test.ts 4 用例
  （T1 迁移锚先红后绿 / T2 零悬挂 / T3 series count+table rows 全覆盖不变量 /
  T4 裁值与 calc 行一致）4/4 绿；seed:db 重浇 27→39 interface / 24→36 link；
  seed:check clean；DB 探针全对。兄弟仓同步：react/vue 零改动（种子唯一源
  shared，无镜像回写）。

- feat(seeds): **账 6 三部解禁批（TB 10424-2018 / TB∕T 3275-2018）tech_req +35**——
  seeds/inspection_technical_requirements.json 406→441（10424 细 10+粗 5 /
  3275 细 12+粗 8；码形 TB∕T 全角 U+2215 对齐字典与挂链；grade 分档 <C30/C30~C45/≥C50
  首批入 tech_req，档位序由 3275 表头列序+两标值序互证+单调性三重支撑）；
  挂链零新增（四组 obj×std JUDGMENT 三键全在 skip）。**挂账**：账 27 RA-TB1
  （10424 硫化物乱码/压碎指标乱码/针片状塌缩/石粉MB 塌缩/级配表）；账 28 RA-TB2
  （3275 石粉MB 三档结构不符/表7/9/10 矩阵）；账 29 无参数面（粗骨料链缺
  吸水率/硫化物/氯化物/有机物 参数四行+紧密空隙率语义变体+岩石抗压强度≥1.5倍
  +云母——参数链扩容批候选）；账 30 < 界符面（碱活性 6 行+10424 预应力坚固性
  <5%——comparison "<" 枚举扩展批：管线 COMPARISONS/判定端/展示面/DB 四处同步）；
  账 31 limitKey 面（冻融吸水率 ×2+3275 预应力坚固性 3 行被 limitKey 不含
  conditions 批内互吞——limitKey 扩列批另立）；账 32 JTG 3420-2020（方法规程
  零 tech_req 面，calc 公式转录归账 1 专门批）。术语映射两处 remark 在案
  （氯化物→氯离子 IP-0004 / 机制砂→人工砂 IP-0181）。守卫先行出红（cement
  441/rebar 441 两计数断言 L4 真红）→ --write → phase --to green 正门消费。
  seed:db 重浇 441 行 + seed:check clean；DB 探针全对（15/20 拆分、针片状三档
  grade 行、挂链 7 条 JUDGMENT）；双门绿。兄弟仓同步：react/vue 零改动
  （种子唯一源 shared，无镜像回写）。

- feat(seeds): **批AG 骨料组批首行导入（GB/T 14685 粗骨料表观密度）**——
  seeds/inspection_technical_requirements.json +1（OBJ-SP01-P3-粗骨料 × IP-0177
  ≥2600 kg/m³，14685 §6.7 pg=10，verified/automatic；OCR 上标³误读为²，单位取
  参数链 IP-0177 声明 kg/m³）；seeds/inspection_object_standards.json +2
  JUDGMENT 补链（细骨料×JGJ 52 / P5×GB/T 50082-2009——既有缺链随批归一；新行
  挂链三键 粗骨料×14685 JUDGMENT 已在 → skip）。挂账：RA-AG 族（14684 表1/3/4/5/6/7/8
  + 14685 表1/2/3/4/5/7/8/9 矩阵限值 OCR 塌缩不导，解锁=原版 PDF 锚定）+
  RA-J52（JGJ 52-2006 语料碎片化灾难级——页面重复/语序打乱/条文说明混正文，整
  标准不导，解锁=语料重灌或 PDF）；细骨料 prose 有值无参数四例不硬凑（细度模数
  §6.1.2 / 机制砂片状 §6.7 / 堆积密度 ≥1400 §6.8 / 不规则颗粒·岩石抗压强度
  粗骨料侧）。lab_dev 重浇 seed:check clean；DB 探针全对（406/194）；双门绿。
  兄弟仓同步：react/vue 零改动（种子唯一源 shared，无镜像回写）。

- feat(seeds): **批R2 JGJ 107-2016 calc 三行导入（钢筋机械连接 prose 面）**——
  seeds/inspection_calculation_methods.json +3（OBJ-SP01-P2 × IP-0087
  steel_tensile sp=3 formula=ROUND_HALF_EVEN 复用现行引擎白名单串 / IP-0154
  simple_avg sp=3 / IP-0151 simple_avg sp=3，全部 report_name_code=null 不扩 RN 面）；
  seeds/inspection_object_standards.json +3 TESTING 补链（P2×JGJ 107-2016 真双链
  J+T 成形 / P2×裸 GB/T 28900 / P5×GB/T 50082-2009——后两枚为 REQ-2026-039 T3
  collectLinkPairs 扫全行暴露的既有缺链，账 21 前置护栏验证码均在字典在册，随批
  归一）。挂账：JGJ 107 表3.0.5/表3.0.7 限值矩阵 OCR 错列塌缩不导（RA-J1/J2，
  解锁=原版 PDF 锚定）；28900 IP-0151 手工法行（specimen_count 未规定不硬凑）；
  IP-0097 不在 P2 对象链不硬凑。guard 随批改：挂链总数 189→192 / calc 绝对计数
  30→33(P2 11→14) / TESTING 面白名单 3→4(+JGJ 107-2016)+50082-2009 版本错位例外。
  lab_dev 重浇 seed:check clean（dedupe dropped 2 variant rows=PK 粒度常态）；
  DB 探针 3 calc 行+4 链全对；shared/nextjs 双门绿。兄弟仓同步：react/vue 零改动
  （种子唯一源 shared，无镜像回写）。

- feat(seeds): **REQ-2026-042 码表清洗（T2.5）**——「——」占位行统一不增加（照
  2026-11-15 既裁「占位归渲染层」）：models/specs/grades 三表共删 23 行；名称去
  「（seed 补全）」注水后缀：5 文件 13 行归正，其中 grades 2 行（'42.5'/'P6'）去后缀
  后与同项目规范行真重复整行删。执行件=`_work/clean-catalog-seeds.py`（确定性变换，
  重跑逐字节一致）。终态行数 models 118 / specs 66 / grades 344 / brands 95 /
  interfaces 104。lab_dev `--reset` 重浇 + seed:check clean。兄弟仓同步清单：
  saas-identity-platform-shared（REQ-2026-042 T1 菜单种子已同批落地 dfd7f09）；
  lab-management-system-nextjs（T3 维护页另 commit）；react/vue 镜像另批挂账。

- fix(seeds): **catalog 4 表退出 SSO 镜像**（2026-11-17 人裁：码表平台级全局字典，无 tenant
  列、端点无租户过滤——镜像副本对任何登录形态同可见，只产生成对重复行）。live 实证：
  等级维护页水泥 grades 每行 ×2（`GR-…-20` + `GR-…-20-sso` 同 sort_order 成对，
  lab_dev catalog 4 表共 648 条 -sso 行）。`seed-db.mjs` SSO_MIRROR_TABLES 删
  brands/models/specs/grades 四目（业务 4 表租户镜像不变）；测试翻转
  tests/seed-db.test.ts「catalog 表仅 code 加后缀」→「catalog 4 表不镜像（返回 null）」。
  lab_dev `seed:db --reset` 重浇后归零（水泥 grades 20→10 行，业务镜像 samples 210
  完好），seed:check clean，shared/nextjs 双门绿。兄弟仓同步：无（灌库转换层单源
  lab shared；saas 家族 seed-db.mjs 无 mirror 特性；lab_test 不灌镜像面不受影响）。
  遗留：lab_prod 若曾带镜像 env 灌库同样存 -sso 码表行，prod 重浇另批（动远程库先过
  prod 政策）。

- fix(seeds): **REQ-2026-041 报告名称↔标准挂链洗链收官（T-2/T-4）+ REQ §6/§3 勘误回填**——
  `inspection_report_name_standards` 洗链（shared 78b1750+dd6eaf2）：A 组检验依据假腿
  42 删（43 行规则 −RN-110-3 移出翻转）+ RN-110-3 GB 50208-2011 T→J 翻转（裁 #9）+
  B 组判定依据 method 错挂 5 换裁（105-2→GB/T 50081-2019 / 108-2→GB/T 25181-2019 /
  109-1/2/3→JTG 3430-2020，裁 #7/#8）+ C 组 RN-103-5 删错挂 J（GB/T 14684-2022 砂
  产品标准，裁 #9），终态 135→**92 行**（TESTING 107→**64** / JUDGMENT **28**）；
  白名单 T 腿 10 保留（实况分布 **50081×4 + JGJ 52-2006×5 + 3430×1**——3430 T 腿仅
  RN-109-1 一条，REQ §3 勘误注记随本 commit）；J 缺失锚 {RN-103-5, RN-104-3}
  （REQ §5 人裁挂账）；J≤1 不变式全绿。护栏 +2（tests/seeds/
  report-name-standards-links.test.ts：①J 腿 obj 链 JUDGMENT 背书，
  JUDGMENT_BACKIN_EXCEPTIONS 钉 RN-105-3|GB 55008-2021 单条例外——REQ §6 勘误回填：
  「现状 J 腿逐个核过全满足」不成立，归一挂账拌合用水域覆盖批人裁三案
  （补链/换挂/删挂）②T 腿 ∈ method 40 锚 ∪ 白名单 3 条）。红绿证据：入红
  evidence_at 2026-11-17T07:51:58+0800 → gate L4 红（两断言 6 J 无背书+43 T 假腿）
  → phase.py --to green 07:52:51 → 全门绿。DB 收口（nextjs 侧 T-3，零代码零测试
  改动）：seed:db --reset 重浇 lab_dev（92 行）→ seed:check clean → psycopg 探针
  15 断言全过 failures=0 → 全量 vitest 926 passed/1 skipped 与 REQ-040 基线全等 →
  双门 gate exit 0（报告 shared `.superpowers/sdd/2026-11-17-req041-rn-wash/
  task-T3-report.md`）。
  contract-test 硬约束 §2 核查无命中（read 面 items/total drop、写面自建
  per-target fixture，零种子行数/行内容钉死）。挂账：react/vue 等消费仓 junction
  消费面镜像另批（standard-gen HISTORY 账 23）；RN-105-3 归一随拌合用水域覆盖批
  人裁三案（账 23①）；RN-110-1 版本错位归一入账 21 扩面。**兄弟仓同步清单**：
  react——报告名称维护关联聚合 / 接样表单标准候选随洗链 role 面镜像核对（账 23③）；
  vue——同 react（账 23③）；其余后端栈 junction 字典消费面另批核对（账 23③）；
  shared 本体零待回放。

- docs(req): **REQ-2026-040 加载态统一收官登记**——行为标准
  `docs/requirements/REQ-2026-040-loading-state.md`（§2 裁定 / §3 规约 / §4 面清单）
  本批落地 nextjs（T1-T7 收口，2026-11-17）：A 组 8 面 B6 翻转（`loading &&
  list.length === 0` 保旧行为 → loading 真值门控）+ B 组 9 面补门控 + C 组锚性质
  校验 + 三 store（sample/receipt/contract）loading 初始值翻转 + 核对面清单收口
  （TechnicalRequirementList 下拉源 / CategoryDictList 树源 / FlowStagePage 可撤回
  子表 / contracts 在位恢复 / ReceiptFormModal 三来源错误条）。台账 README 状态行
  改「已上线（2026-11-17，nextjs T1-T7 收口双门绿；react/vue 镜像挂账另批）」。
  双门绿（shared+nextjs gate exit 0）。**兄弟仓同步清单**：react——A/B 组加载态
  镜像 + store 初始值翻转 + dom 测试移植（standard-gen HISTORY 账 22）；vue——
  同 react（账 22）；shared 本体零待回放（本批 shared 无代码改动，仅文档）。

- fix(seeds): **REQ-2026-039 技术要求页判定挂链（role=JUDGMENT）过滤与假链清洗**——
  inspection_object_standards 一轮 17 条假 JUDGMENT 链清洗（16 删 1 翻转 GBJ 82-85@P5
  →TESTING，REQ §4 人批件）+ §5 判定行缺链补 2（GB/T 200-2025@P1 /
  GB/T 20065-2016@P2 各 +1 JUDGMENT）+ 二轮 TESTING 面镜像错挂 30 删 2 翻转
  （GB/T 21372-2024@P1 / GB/T 51003-2014@P7 →JUDGMENT）+ calc 行 4 迁 1 删
  （REQ §8 人批件，随迁 inspection_calculation_methods 种子），终态挂链 219→189
  （TESTING 83 / JUDGMENT 106）/ calc 31→30（shared 77efdcc 一轮 / 4a7f6bd 二轮 /
  f29abdb SP-SMK-001 专项 smoke 种子行删除）。护栏测试在消费仓 nextjs
  （tests/seeds/judgment-link-snapshot.test.ts：判定行⇒JUDGMENT 不变量含 2 版本错位
  显式例外钉锚 / 快照锚 EXPECTED_JUDGMENT_STANDARDS 106 对同源导出 / TESTING 链
  零 verdict 不变量，全绿）。DB 收口（nextjs 侧）：seed:db -- --reset 全量重浇
  lab_dev（二轮含删行，常规浇不删孤儿链）→ seed:check clean；psycopg 探针 7 项全过
  failures=0（总行 189 / GBJ 82-85@P5 翻转 / 17 假链零 JUDGMENT 残留 /
  GB 175-2023@P1 仅 JUDGMENT / 2 补链在 DB / DB JUDGMENT 集合=锚 106 对逐位等价 /
  specialties 零 SP-SMK* 且总行 9，报告 nextjs `_work/req039-probe-report.txt`）。
  双门绿（shared+nextjs gate exit 0）。挂账：react/vue 树过滤镜像与其余后端栈字典
  消费面另批（standard-gen HISTORY 账 20）；JGJ 52 / GB/T 50082 / GB/T 28900 版本
  错位归一另批（账 21，ensureObjectStandardLinks standards-存在性护栏随下次导入批
  前置）。**兄弟仓同步清单**：react——技术要求页树 JUDGMENT 过滤+计算方法页 TESTING
  过滤镜像（账 20）；vue——同 react（账 20）；其余后端栈（springboot/aspnetcore/
  fastapi/rails/kotlin/laravel/go/django）——inspection_object_standards 字典消费面
  role 语义另批核对（账 20）；shared 本体零待回放。

- feat(seeds): **钢筋组导面批——三部标准 tech_req +129 行（种子 284→413）+ 搭车修 HF-1~5（删 8/改 21，终态 405）+ 字典 +23 码（596→619）**
  （四批规划第二批，三裁纪律同批水泥导面；plan `docs/superpowers/plans/2026-11-16-rebar-domain-surface-import.md`，
  shared 提交 7811850 字典 / faf7a86 sort_order 修正 / 8c89b7e 技术要求+搭车）。
  三部明细（OBJ-SP01-P1，语料 dump `_work/surface/GB_1499.1-2024.txt` 等三份为真源，禁再打 Weaviate）：
  **GB 1499.1-2024 +11**（终态 19=8 旧+11 新）/ **GB 1499.2-2024 +109**（终态 188=79 旧+109 新，
  搭车删 8 后 180）/ **GB/T 20065-2016 +9**（终态 29=20 旧+9 新）；管线
  `tech-req:import --domain rebar --write` acceptedNew=129 / rejected=0 / medCount=87
  （flag 面 HIGH 42 / MED 87，旗标行 remark 留痕进人看闸）。
  字典 +23（IP-0598~IP-0620，照批 200 形状；faf7a86 修正 23 新码 sort_order 对齐
  code 序号 IP-0598→598…IP-0620→620，纠正抽取端 per-std 尾段分配）。
  **管线 enrich 语义落库实证**：IP-0605 ≥0.055/≥0.060/≥0.065 → min_value 0.055/0.060/0.065
  （string 行同样回填，IP-0597 先例同款）。**三冲突+flag 行 remark 留痕**：Si 0.80 dump 为准
  （gap 报告 0.55 冲突）/反弯 D+1d 推导链/HRB600 合并格继承/疲劳应力范围 195 MPa；
  20065 疲劳两行人裁形状：IP-0103 8.4.2 target=`2×10^6 次循环 0.7Fm～(0.7Fm+Fr) 不断裂`、
  value_type=string+judgment_mode=manual（字典单位 kN 不适用，选择性协商项入 remark）。
  **搭车修 HF-1~5**（人看闸 2026-11-16 过目；删 8/改 21）：HF-1 删 7 条 clause='' 草稿行
  （IP-0086/0087/0150/0151/0559/0560，8 键判据）+删 IP-0153 clause=表4 Φ6~12 min/max 空值
  同键 dup 1；HF-2 IP-0151 1499.2 存活 9 行 min_value 回填（普通 5 行 7.5 / E 4 行 9.0，
  零 null）；HF-3 含于 HF-1 清单（IP-0559/0560 brand=HRB400 草稿 2 行随删）；HF-4
  IP-0559/0560 ×8 remark 逐字订正（实测强屈比 Rm/ReL ≥1.25 / 实测超强比 R°eL/ReL ≤1.30，
  小数落 expression 注记 V014 挂账）；HF-5 1499.1 IP-0086/IP-0150 clause=表6 remark 补注记
  （Rp0.2 / 出厂检验时准许采用A / 仲裁检验时采用A / Agt/A 替代方向已对 dump 原文复核），
  值面零动。**HISTORY 账 9 随批收口**：6 组 8 键全等真重复（curated×抽取 disagreement）
  的 curated 草稿行随 HF-1 删行出局、文档抽取行存活——全库 405 行 8 键唯一（护栏断言
  即收口证据）；⚠ 消费点注记：DataEntryPage specStandardYield IP-0086 唯一 verified 行
  随裁定翻转为文档抽取行（≥300 MPa HPB300）。
  挂账 8 条（RA-D1~D8，逐条缺口+解锁条件见 nextjs `_work/surface/rebar-deferred.md`，
  总账见 standard-gen HISTORY 账 19）：RA-D1 20065 表3 断后伸长率 A 五档 OCR 残缺 /
  RA-D2 20065 表2 外形尺寸逐档矩阵错序 / RA-D3 20065 松弛四行继承未逐格核（与 RA-D1
  同次解锁）/ RA-D4 1499.1 5.4.2 盘条交货批量面不导（硬约束 4 裁定）/ RA-D5~D7 1499.2
  表3 内径 11 档+横肋高 13 档+横肋间距 15 档 OCR 错位 / RA-D8 1499.1 表3 Φ28~40 档
  dump 缺失（语料块截断，人裁不猜测）。
  DB 收口：seed:db **--reset 全量重浇**（本批含删行+改键搭车，常规浇必留旧键孤儿——
  批水泥/批 1 同款指纹：改键搭车唯一收口=--reset，dev 库专用）→ seed:check clean
  （calc 面 dropped 2 = PK 粒度常态）。lab_dev 探针 12 项（psycopg UTF-8 落盘）：
  tech_req 总面 405、三部 19/180/29、DB↔种子 23 字段多重集深等、IP-0151 9 行
  7.5/9.0 零 null、IP-0152 表7/page 11/D=5d、IP-0153 Φ6~12 表4/page 9/-5.5/5.5 唯一行、
  搭车删行零残留（三部内 clause 空面清零）、HF-4/5 remark 逐字在册、疲劳 string/manual
  行+195 MPa remark 在册、IP-0605 enrich ×3、字典 619+23 新码在册、绑定面 511 零触碰
  （per-std 6/7/0）、8 键全库唯一。双门绿（shared+nextjs exit 0）。同步清单：
  **react/vue 零改动**（本批只动 shared 种子+字典+nextjs 护栏，消费仓无代码面变化）；
  nextjs CHANGELOG 同批条（护栏消费侧）。

- feat(seeds): **水泥组导面批——三部标准 tech_req +76 行（种子 208→284）+ 字典 +2 码（594→596）+ 在库 5 行搭车修**
  （2026-11-16 人裁三裁：①按域分四批（水泥组/钢筋组/骨料组/方法标），本批为首；
  ②HIGH 直解全导、MED 双证过照导（旗标进人看闸）、LOW/双证失败挂账不导；
  ③疑点随域批搭车修。plan `docs/superpowers/plans/2026-11-16-cement-domain-surface-import.md`，
  shared 提交 fd71251 字典 / d3d39dd 技术要求）。
  三部明细（OBJ-SP01-P1，语料 dump `_work/surface/GB_175-2023.txt` 等三份为真源，禁再打 Weaviate）：
  **GB 175-2023 +53**（终态 58=5 旧+53 新：表 4 品种×限值矩阵 MED 双证面+表 5 强度 7 档
  IP-0555~0558，含 62.5 档 3d 对与 52.5R 同值旗标 MED；另含水溶性铬挂账面相关行见挂账清单）、
  **GB/T 3183-2025 +12**（终态 20=8 旧+12 新：细度复用 IP-0217 记 sieve=80μm 方孔筛、
  放射性 IP-0062 单行 ≤1.0 合一照批 200 挂账先例）、**GB/T 2015-2017 +11**（终态 23=12 旧+11 新：
  白度 IP-0597 两行 model 挂等级 P·W-1/P·W-2、细度复用 IP-0549 45μm、碱含量选择性行
  照批 200 6.2 先例 remark 记条件）。
  字典 +2（fd71251，照 IP-0590~0595 行形状）：IP-0596 水溶性铬（Ⅵ）unit=mg/kg（三部共用）/
  IP-0597 白度 unit=None（无量纲亨特白度，2015 独有）。
  **搭车 5 行**（人看闸 2026-11-16 过目；既有行改动仅此 5 行——4 行 42.5 补挂+氯离子
  旧键行删新键行插，其余既有行深等零漂移；种子文件既有 6 组 8 键全等重复对与账 9
  一致原样未动）：
  ①氯离子 IP-0004 model `P·O 42.5`→`''`（全品种适用，限值品种无关——**model 是 8 键 PK
  维度，改键=旧键行删+新键行插**，账 17 两列混用就此收口）+clause 7.1 表4/page 6+
  remark 品种注记；②IP-0555~0558 42.5 四行 clause `7.4.3 表5`/page 7 补挂；
  ③其中 IP-0555 **D5 裁值 4.0**（人看闸 2026-11-16：语料 ≥4.0 为准，在库 remark 3.5 记废，
  min_value null→4.0+remark 改写）。
  **sort_order 偏差口径（ruling）**：candidates 抽取端 per-std 分配（各 std 现行 max+10）
  被管线全局 append 尾段 max+10 覆盖（批 200 同机制），终态 175=1424 起/3183=1954 起/
  2015=2074 起、步进 10，全库零撞——只记录不改码。
  挂账 5 条（D1~D5，逐条缺口+解锁条件见 nextjs `_work/surface/cement-deferred.md`，
  总账见 standard-gen HISTORY 账 18）：D1/D3 水溶性铬 ≤10 mg/kg 双证失败（GB 31893 原文
  锚定解锁，双标准一次受益）/ D2 175 细度 45μm 方向存疑（原版 PDF 锚定）/ D4 175 表5
  五档 28d 对 OCR 未读出（原版表5 锚定）/ D5 已裁值收口（见搭车③）。
  DB 收口：seed:db append-only 常规浇 → seed:check **红（陈旧 1 行）**→ 根因=氯离子行
  model 改键（plan 预估「model 非键」误判——model 在 8 键 PK 内，upsert 按新键插入、
  旧键行残留）→ `seed:db -- --reset` 全量重浇（dev 库专用）→ seed:check clean。
  **指纹：改键搭车必炸常规浇，--reset 是唯一收口**。lab_dev 探针六项（psycopg UTF-8
  落盘）：三部行数 58/20/23 与新旧拆分 5+53/8+12/12+11 逐值过；搭车 5 行逐字段终态过；
  白度 2 行 vt=string/min 89·87/expression ≥89·≥87；字典 596 两新码在册；tech_req 总面
  278=284−dedupe 6（既有账 9 组）；绑定面 511 零触碰；8 键全库唯一。
  **白度 vt 消费面结论**：判定链（cement-strength autoVerdict/requirement 格式化/
  reportTemplateSeed/DynamicFormRenderer）全部以 comparison+minValue/maxValue 为消费键，
  `value_type` 仅 range 分支读——`string`+min_value 行走 numeric ≥ 路径正常判定，
  不忽略不报错；`string` 唯一作用=tech-req-gate 单位空豁免+报表 expression 显示。
  双门绿（shared + nextjs exit 0）。同步清单：**react/vue 零改动**（本批只动 shared
  种子+字典+nextjs 护栏，消费仓无代码面变化）；nextjs CHANGELOG 同批条（护栏消费侧）。

- feat(seeds): **JC/T 600-2010 龄期进参数名迁移批——16 行泛龄期码拆四龄期码（IP-0555~0558），spec 龄期迁入参数名，绑定 2→4**
  （2026-11-15 人批；plan `docs/superpowers/plans/2026-11-15-age-in-parameter-name-migration.md`）。
  旧键 (JC/T 600-2010, IP-0055 抗压强度 / IP-0056 抗折强度) 四行携 spec=3d/28d 表龄期 →
  按龄期拆码：IP-0555=3 天抗折强度 / IP-0556=3 天抗压强度 / IP-0557=28 天抗折强度 /
  IP-0558=28 天抗压强度；spec 清 '' 哨兵、brand=强度等级（32.5/32.5R/42.5/42.5R）、
  comparison 全 ≥、clause 表1。16 值映射表（brand → 0556/0558/0555/0557 min_value）：
  32.5→11/32.5/2.5/5.5；32.5R→16/32.5/3.5/5.5；42.5→16/42.5/3.5/6.5；42.5R→21/42.5/4/6.5
  （0556/0558 抗压、0555/0557 抗折）。绑定面 (JC/T 600-2010, IP-0555~0558) 各 1（2→4，
  旧键绑定删）；**泛码零误伤**——IP-0055/0056 其余绑定 38 行（30 标准）与 tech-req 行
  （GB/T 50081-2019 等）原样保留，GB/T 50081-2019 泛龄期行本批不迁（留观，同改键待后续人裁）。
  护栏：nextjs `tests/seeds/age-param-migration.test.ts` 钉 16 行终态+绑定 4+泛码零误伤
  （nextjs 6c9d875）。DB 收口：seed:db `--reset` 全量重灌（改码换键收旧键孤儿行的既有机制）→
  seed:check clean；lab_dev 探针 16 行逐值过 / 旧键 (JC/T 600, IP-0055/0056) 零残留 /
  GB/T 200-2025 35 行在 / tech_req 总面 202（种子 208−dedupe 6）/ 字典 594 不动。
  双门绿（shared + nextjs exit 0）。同步清单：react/vue 零改动（本批只动 shared 种子，
  消费仓经镜像吃种子无代码面变化）。

- feat(seeds): **GB/T 200-2025 全参数导入批——tech_req +21 行（种子 187→208）+ 字典 +6 码（588→594）**
  （2026-11-15，用户启动令「全参数导入批」；账 16 重开→收口；tech-req 管线 --write，
  dry-run acceptedNew=21/rejected=0/MED 旗标 12）。字典 6 码（64fdc3f）：IP-0590 3天水化热 /
  IP-0591 7天水化热 / IP-0592 28天水化热 / IP-0593 硅酸三钙含量 / IP-0594 硅酸二钙含量 /
  IP-0595 铝酸三钙含量。21 行明细（sort_order 1214..1414，管线写入分配）：化学 5 行
  6.1.1-6.1.5（IP-0006 氧化镁≤5.0（压蒸安定性合格放宽 6.0 入 remark）/IP-0008 三氧化硫≤3.5 /
  IP-0218 烧失量≤3.0 / IP-0385 不溶物≤0.75 / IP-0004 氯离子≤0.060）+ 碱 1 行 6.2
  （IP-0007≤0.60 选择性指标）+ 矿物 4 行 6.3/表1（IP-0593 C3S≤55 中热 / IP-0595 C3A≤6 中热 /
  IP-0594 C2S≥40 低热 / IP-0595 C3A≤6 低热）+ 物理 3 行 6.4.1/6.4.2（IP-0220 比表面积≥250
  m²/kg / IP-0550 初凝≥60min / IP-0551 终凝≤720min）+ 表3 水化热 6 行 6.4.6/表3（IP-0590
  3d：中热42.5≤241/低热32.5≤187/低热42.5≤220；IP-0591 7d：中热42.5≤283/低热32.5≤220/
  低热42.5≤250，表3 原文「<」归一「≤」逐行 remark 人批先例）+ 28d 水化热 2 行 6.4.7
  （IP-0592：低热32.5≤280/低热42.5≤300）。6.4.7 源块曾错挂 clause_id=32.5（OCR 错挂，
  文本锚定双证抽法纠正指纹）。挂账面五项不导（去向见 standard-gen HISTORY 账 16）：
  熟料 4.1/4.2（对象树无熟料对象）、6.1.6 水溶性铬(VI)（GB 31893 委托）、6.4.3/7.7
  安定性合格型、6.4.5 低热 90d 抗压≥62.5（既有裁定）、6.5 放射性（IP-0062 撞 8 键 PK
  变体面）。DB 收口：seed:db append-only 常规浇（无需 --reset）→ seed:check clean（漂移
  清单空）；lab_dev 探针 35 行（14 旧表2 + 21 新）逐值过、字典 6 码在册。双门绿（shared +
  nextjs exit 0）。同步清单：react/vue 零改动（本批只动 shared 种子+字典，消费仓只经
  镜像吃种子，无代码面变化）；nextjs CHANGELOG 同批条（管线消费侧）。

- fix(seeds): **GB/T 200-2025 龄期错位修复批——低热 3d 错挂行 ×4 删除 + 7d 列补齐，终态 14 行**（2026-11-15，
  2026-11-15 用户启动令人批；批史第二例管线外最小删除，3183 先例同款）。根因=批 C1 抽取端 v1
  缺列归因推断错误：低热水泥表2 3d 本为「—」（标准无要求），语料「—」被 OCR 整格吞，v1 归因
  「OCR 丢 7d 对」把 7d 真值错挂 3d（IP-0555/0556 × 低热水泥 × 32.5/42.5），4 行 verified 带
  「3 天…」自洽 remark 蒙过管线与评审；中热 7d 列因字典无 7 天码整列丢失。修复三件：
  ① 参数字典补 IP-0588=7天抗折强度 / IP-0589=7天抗压强度（顺延 0587，fb31cad）；
  ② 种子删 4 错行（6676545，node 同管线格式重写，diff 恰删零新增）；
  ③ 抽取端 v2 重抽 --write +6 行 7d 行（acceptedNew=6/skippedExisting=8/MED 旗标 8/拒收 0；
  中热 c7≥22.0/f7≥4.5 + 低热 32.5 c7≥10.0/f7≥3.0 + 低热 42.5 c7≥13.0/f7≥3.5；种子 185→187 行、
  DB tech_req 179→181（种子 187 − dedupe 6 既有账 9 组，本批 0 新增）。v2 机制=缺列归因禁令机械化：列 schema 由年龄行
  钉死（v1 误当超发垃圾 token 丢弃——实为真实列序「7 d | 7 d 3 d 28 d 3 d 28 d」与中热完整行 6 值
  1:1）；强度类型映射 8 枚举由中热完整行约束解唯一；低热缺列定位=人裁 pin（2026-11-15 标准原文
  人核）+ 约束解唯一双保险，pin 错/歧义未消即 exit 1（v1 审计只报不拦 → v2 起真拦）。
  6.4.5 低热 90d 抗压≥62.5 特殊条款仍挂账不进本批（既有裁定）。DB 收口：seed:db 常规浇后
  seed:check 红（陈旧 4 行）→ `seed:db -- --reset` 全量重浇 → clean；lab_dev 探针 14 行/低热 3d
  残留 0/7d 行 6 逐值过。护栏面：tests 无绝对计数断言零改动。双门绿（shared+nextjs exit 0）。
  同步清单：nextjs CHANGELOG 同批条（管线消费侧）；react/vue 不涉种子消费零改动。


- feat(seeds): **批 C1 收官——ce 域三部水泥产品标准 tech_req +32 行**（2026-11-15，
  tech-req 管线 --write，OBJ-SP01-P1；种子 153→185 行、diff 864 insertions=32×27）——
  ① GB/T 2015-2017（白色硅酸盐水泥）+12：表1 双护栏选表（clause_id+caption）+ 邻接
  prose 6.2.5 规则 #13，3 等级（32.5/42.5/52.5）× 4 参数（IP-0555 3d抗折 / IP-0557
  28d抗折 / IP-0556 3d抗压 / IP-0558 28d抗压，列→参数由组×年龄推导禁按列号硬编码），
  全 HIGH 直解；唯一脏点 32.5 行 3d 抗压 raw「≥>12.0」规则 #2 取首位比较符→「≥12.0」；
  自检锚 28d 抗压值==等级值三等级全成立。② GB/T 3183-2025（砌筑水泥）+8（fix round 1
  终态）：真表混合龄期（ground truth=gb-gbt.com 全文页同源实证，快照 nextjs
  `_work/gbt3183-groundtruth.html`）——12.5/22.5 低龄抗折=7d 无码撤行（首轮 9 行版
  IP-0555 两行撤，**批史首例裁定授权管线外最小删除**）、32.5 低龄=3d 保留 + 补 1 行
  32.5×IP-0556 3d 抗压≥10.0（首轮漏解析面，HIGH 直解，acceptedNew=1/skipped 7 零手改
  路径）；唯一 MED（12.5 低龄抗折「>1.5」→≥1.5 规则 #3 惯例归一）随撤行消失。
  ③ GB/T 200-2025（中热/低热硅酸盐水泥）+12：**品种→model 人裁首航**——表2 按品种×
  等级分行，model 落品种名 verbatim（中热水泥/低热水泥）、禁裸 grade 落行；中热42.5
  4 行 HIGH 直解，低热 8 行整行 MED（7d 对 OCR 整对丢弃靠三判对位；低热42.5 3d 抗压
  ≥13.0 三判行保 MED；「≥>3.5」规则 #2 确定性归一不降级）；GROUP BY param,grade,model
  探针证双品种同等级不互吞（8 键 PK model 维度首次真消费）；--write 后复跑 dry-run
  acceptedNew=0/skippedExisting=12 append-only 幂等实证。数字面：DB lab_dev/lab_test
  tech_req 147→179（seed 185 − dedupe 6 既有账 9 组，本批 0 新增）；tests/seeds 18/18
  绿、seed:check clean 双库、lab_test `-sso` 8 表 id/code 列探针全 0（mirror=off 无
  污染）；grade 列无 FK（pg_constraint 实测仅 object/parameter/judgment_standard 三
  FK），容忍面（对象域 code∨name 匹配口径）终态 25 行=本批 4（3183 12.5/22.5 无字典
  行 12.5×2+22.5×2，32.5 有 GR-OBJ-SP01-P1-32-5）+ 既有 21。不入库面挂账账 16：
  7d 抗压/抗折（中热42.5 ≥22.0/≥4.5 等已解析在册）、水化热表3 整表、矿物组成
  C3S/C2S/C3A 表1 整表、低热 90d 抗压/28d 水化热——全缺 IP 码不入库。三标准品种
  单一，model=''（2015/3183 人裁同款）；grade=等级真值、brand/spec/sieve '' 哨兵。
  抽取端+探针过程件在 nextjs 仓 `_work/`（import-2015/3183/200-tech-req.py、三部
  candidates/report 件、probe-200-db.py 等，gitignore 不入库）。同步清单：无仓内
  同步件（nextjs 仓内零变更，数据单源=本仓 seeds）。
- feat(seeds): **批 R1 Task 3 第二部标准入库——GB/T 20065-2016（预应力混凝土用螺纹钢筋）
  tech_req +20 行**（2026-11-15，tech-req 管线 --write，OBJ-SP01-P2）——**8 键 PK 扩维后
  首批真变体面**：表3 力学性能按 PSB 级别分行（PSB785/830/930/1080/1200 × 4 参数），
  grade 落级别真值、brand/model/spec/sieve '' 哨兵。IP-0086 屈服强度 ReL≥785/830/930/
  1080/1200 MPa + IP-0087 抗拉强度 Rm≥980/1030/1080/1230/1330 MPa 全 HIGH 直解（逐行
  OCR 锚）；IP-0151 Agt≥3.5% 与 IP-0100 应力松弛（1000h ≤4.0%，conditions=「初始应力
  =0.7Rm，1000h」）为表3 合并格内联——PSB930 直解 HIGH + 其余 4 牌号继承 MED（合并格
  判定三依据：值落中间行/表级量限「不小于」/限值表每牌号行必须有限值，人批详查结论=
  接受继承，medCount=8 过门旗标）；断后伸长率 A 列语料全空+垃圾行「1P0.21TV=」不可恢复
  →缺列明说不硬凑（本批无 IP-0150 行）；表4 出厂检验排除（誘误词护栏）、本标准无独立
  重量偏差限值表（无 IP-0153 行）；表3 标题=邻接 prose 7.4.1（规则 #12，锚审计 32 条
  全过）。dry-run 20/20 过门 0 拒收 retired=0；lab_dev 重浇 tech_req 147 行 upserted
  （seed JSON 153 − PK 粒度 dedupe dropped 6，6 组均 1499.2 两来源行既有挂账账 9，本批
  0 新增）、seed:check clean（26 表 mirror=on）；DB 探针 count=20 全 verified、grade<>''
  20 行 / grade='' 0 行。标准字典补行：inspection_standards.json +1（GB/T 20065-2016
  active/sort_order 11/源路径 raw/standards/pdf/GB_T 20065-2016.pdf——FK
  tech_req_judgment_standard_fk 依赖，GB 1499.1-2024 行后族邻插入）。管线依赖修复：
  nextjs 同日条（limitKey 4→8 键，V020 收尾缺口，批 R1 Task 3 人批裁定）。抽取端+探针
  过程件在 nextjs 仓 `_work/`（import-20065-tech-req.py / 20065-candidates.json /
  20065-tech-req-import-report.md）。同步清单：nextjs 同日条（fix 上述）。
- feat(seeds): **批 R1 Task 2 首部标准入库——GB 1499.1-2024（热轧光圆钢筋）tech_req +8 行**
  （2026-11-15，tech-req 管线 --write，OBJ-SP01-P2）：表4 重量偏差 3 行（IP-0153 range
  ±5.5/±4.5/±3.5，spec Φ6~12/Φ14~20/Φ22~25）+ 表6 力学性能 5 行（IP-0086 ≥300 MPa /
  IP-0087 ≥420 MPa / IP-0150 ≥25% / IP-0151 ≥10.0% / IP-0155 D=d eq，唯一牌号 HPB300，
  变体列 '' 哨兵、牌号进 remark）；全 HIGH 置信、dry-run 8/8 过门 0 拒收、无 superseded；
  lab_dev 重浇 127 行 upserted（seed JSON 133 行 − PK 粒度 dedupe dropped 6，6 组均为
  1499.2 curated×抽取两来源行既有挂账账 9，本批 0 新增）、seed:check clean；
  DB 探针 count=8 实值核对过。抽取端+探针过程件在 nextjs 仓 `_work/`（import-14991-tech-req.py /
  14991-candidates.json / 14991-tech-req-import-report.md / probe-14991-*.py）。同步清单：无
  （消费仓镜像面 B1 已退役，数据单源=本仓 seeds）。
- feat(schema): **tech_req PK 扩维 3→8 列（方案 A 人批 2026-11-15，standard-gen 挂账 3 收口）**——
  inspection_technical_requirements PK=(obj,param,std,brand,model,spec,grade,sieve)、变体列
  NOT NULL DEFAULT ''（'' 哨兵=不限维度）、撤 brand/model/grade/spec 四字典 FK（'' 过不了
  FK/set null 破 NOT NULL PK）；0010 迁移带 NULL→'' 回填；seeds tech_req 5 变体列 null→''
  归一（125 行 339 处）+ brands HRB600/CPB550 rename；seed:db 双库 41→119 行（dropped 6=
  curated×抽取 8 键同维度两来源行，内容有出入 unit/target_value/sort_order，挂账 HISTORY
  账 9；brand 9 值/spec 5 值字典缺口挂账账 10，specimen-config 通道）。同步清单：nextjs 同日条
  （schema 镜像+db 层 dup 8 键+pipeline coerce）；**兄弟后端仓同步挂账 HISTORY 账 11**。
- feat(seeds): 样品界面配置支首批落库（批 I，2026-11-15）——specimen 管线 --write 直写五文件：
  inspection_report_name_interfaces.json（sri-mech-joint v1→v2 jointType options=JGJ 107-2016
  五接头类型）+ inspection_report_name_links.json（5 links）+ inspection_brands/grades/models/specs.json
  （字典首批按需供货 8 append + 6 补全行收敛 update）；幂等复跑全 skip 实证；
  manifest 真源与管线在 nextjs 仓（standard-gen Step 4.5），护栏测试 tests/seeds/specimen-config.test.ts。
- chore(seeds): **B1 种子唯一源改造收官条**（Phase1-4 全闭环，2026-11-14）——种子唯一源=本仓
  `seeds/`（管线 --write 直写人批 + seed-db.mjs 直灌 + seed-drift-check 漂移门）；消费仓镜像面
  （nextjs src/seeds、src/data/generated、vendor/msw/src/seeds+fixtures 导出面、react
  src/data/generated）随 Phase4 整体退役（nextjs 36c578d / react 59af64e）。记忆条
  seeddb-pour-source-vendor-fixtures 与 seed-mirror-cascade-single-source 已改写收口
  （灌库链=shared 直读单条，镜像级联排查退役；模板单源方向与 IP-0554 先例保留）。
  spec/plan 见 suite 仓 `docs/superpowers/{specs,plans}/2026-11-14-seeds-single-source-b1*.md`。
  同步清单：nextjs（Task 11/12/13 三条已记）、react（Task 11/13 已记）。
- feat(seeds): **B1 Phase2 Task6 灌库收拢收官**——① scripts/seed-drift-check.mjs 漂移检测
  （种子按灌库同款语义 dedupe+mirror 算库应有面 vs 库逐行 canonical 对比 + 列集对比，
  不符 exit 1；canonical 归一 ISO datetime/numeric scale/jsonb 深排序三类假差实证消解）；
  ② seed-db.mjs 四修：buildUpsertSql 列集改全行并集并返回 cols（values 展开同列集，
  bind 数错位实证）、catalog 4 表镜像不注入 tenant_id（库无此列，ts 注释过时，lab_dev
  schema 实证）、mirror env 键改家族统一 SAAS_TENANT_ID、dedupeByPk 导出；③ 种子补齐
  NOT NULL 默认值列（库面真值实证）：sample_receipts 补 retest_mode(none)×208 +
  ext({})×210、test_records 补 ext({})×150（dump 快照早于列演化）；SP-SMK-001 date-only
  时间戳归真值 instant（2026-08-17T16:00:00Z）。lab_dev --reset 重灌 26 表 + drift clean
  （mirror=on）实证。tests: seed-db.test.ts 9 pass / seed-drift-check.test.ts 3 pass。
  同步清单：nextjs 仓薄壳化主条（seed:db/seed:check 指 shared，commit bb8ed40）。
- fix(seeds+scripts): **B1 Phase2 Task5 等值验证三修**（临时库 lab_equiv_a/b 双链对灌，
  用完即 DROP；报告 _work/equiv-report.md）——① seeds/inspection_param_interfaces.json
  4 行键大小写/时间戳死值修复（camelCase createdAt/updatedAt→snake；2026-11-10 死值
  按 fixtures 真值归 2026-01-01——三链分叉死值从未进库面）；② 种子补 2 个 FK 合成字典行
  （brands 91→92 `32.5`、specs 63→64 `3d`，ts 链 synthesize 形状，与 lab_dev 实测库面
  一致）；③ seed-db.mjs 补 dedupeByPk（PK 变体行灌库前去重，语义照 nextjs dedupe：
  非空字段多者胜/平局保首行；calc 报告级 2 行 dropped=2 实证）+ post-flight 对账基线改
  用去重后行数。等值结论：26 表 12 全等，14 差全归 a（SSO mirror 缺口→Task6 前置）/
  b（fixtures 陈旧面，种子胜出）/c（时间戳语义）三类，shared 为准。
  同步清单：nextjs 仓 B1 Phase2 主条（Task6 换链时回放）。
- refactor(seeds): **seeds-parity 门退役**（B1 Phase1 收官件，与 nextjs 同批）——删
  tests/seeds-parity.test.ts（shared ↔ nextjs src/seeds 双源 sha256 漂移防护，镜像双写
  约定的执行器）+ ci.yml sibling checkout 步摘除 + ARCHITECTURE 摘引用。本仓此后
  shared/seeds 唯一手写源（管线 --write 直写，人批 diff），镜像面废除。种子行集零变化。
  同步清单：nextjs 仓 B1 Phase1 主条（三管线切源 + 五护栏切锚 + parameter-dimension-deps
  搬家，commit 9b3e3d3 / ec652b2 / 16d1f23）。
- refactor(seeds): 删报告名称冒烟占位行 CAT-SMK-001「报告类别 smoke」（2026-11-14 人裁）——
  种子 31→30，与 nextjs 四镜像同批删行；lab_dev 14 行陈旧委托单对齐现种子 RN-101 后
  删类别行，全库引用清零。nextjs 护栏转正：entryToReportChain 撤豁免过滤（每个报告
  名称须有参数关联，RED→GREEN）。
  同步清单：nextjs 四镜像删行 + 护栏断言（随批回放）；contract-test seed.ts 删死常量
  smokeReportName。
- feat(db+seeds): **批H 三件**——① V018 calc PK 补 testing_standard_code 维度：schema
  `inspection_calculation_methods` PK 三列 `(obj,param,std)`（约束名历史遗留不改），testing_standard_code
  NOT NULL + FK set null→no action（**行为变更**：删被引用标准码由静默置空变报错阻断），迁移
  0009_sturdy_romulus.sql 已应用 lab_dev；② IP-0554 并入 IP-0006 + JC/T 600 补绑 IP-0006 种子回放
  （5 种子 byte-equal，ip-0554-merge guard 测试在 nextjs 仓封面）；③ 101 模板单源 assets/templates
  同步批H（IP-0554→IP-0006 4 处 param 标签）+ sample_receipts prettier 格式回放。双门绿。
  同步清单：nextjs 批H 主条（fd70c6e / aafc233）；lab-react / lab-vue 模板 parity 回放
  （7af221e / c6bedf6）。
- feat(seeds): IP-0002 安定性新行回放（lab-nextjs 批F 人裁落点同批）——
  inspection_calculation_methods.json +IP-0002 行（OBJ-SP01-P1 × GB 175-2023，
  manual×2；按 seeds-parity 门契约与 nextjs src/seeds 快照 byte-equal，真实导入
  时间戳）；nextjs 侧详单（--write 落盘 + seed:db 重浇 + file: 依赖陈旧副本指纹
  复发处置）见 nextjs CHANGELOG 同日条。
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
- _*12 个 ck_* CHECK 约束_*（contracts.status / receipts.flow_status /
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
