# CHANGELOG — lab-management-system-shared

格式参照 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]

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
