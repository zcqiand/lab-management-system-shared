# CHANGELOG — lab-management-system-shared

格式参照 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]

- feat(seeds): **批R14——GB/T 18242-2025 弹性体/塑性体改性沥青防水卷材 tech-req 全面导首入库（③语料产线第 14 部，wp 防水材料域产品标首例）**——
  inspection_technical_requirements.json +38 行（543→581）。**人批三答
  （2026-11-21）**：单标批（JGJ 107-2016/GB 55008-2021 排除——107 grade×直径
  两维+相对限值 ≥1.25fyk/fstk 不合固定值行形；55008 设计构造面为主净面小）/
  全面导（8 绑参限值面+补绑定 4 参+立码 8 参，净面 38 行）/文字判定面 eq 文本
  行入库 16 行（52 行 eq 先例形）。**人批中断修正（最高优先）**：只导 2025，
  **GB18242-2008 退役**——status→superseded 软退役（retireSuperseded 机制在
  库；名下 tech-req 0 行=翻转面空；9 条 std-bind+sample_receipts 历史面不动
  保 FK；UI standards status 过滤面挂账——API listStandardsParams 已支持
  status 参数）。**行面（数值 22）**：表1 厚度×2（IP-0396 spec=3mm/4mm
  ≥3.0/≥4.0→≥3/≥4 mm；最小单值 2.7/3.7 同 PK 统计面变体挂账）+ 可溶物×2
  （IP-0009 spec=3mm/4mm ≥2100/2900 g/m²）+ 表2/表3 拉力×4（IP-0010
  model=SBS/APP × grade=Ⅰ型/Ⅱ型 ≥500/800 N/50mm）+ 延伸率×4（IP-0044
  ≥30/40/25/40 %）+ 表2续/表3续 吸水率×1（IP-0059 ≤2.0→≤2 %，23℃,7d）+
  渗油性×1（IP-0643 ≤2 张立码）+ 矿物粒料粘附性×1（IP-0644 ≤2.0→≤2 g
  立码）+ 保持率×1（IP-0641 ≥90 % 立码；OCR 双碎片歧义取引用层项目名 MED
  人看闸）+ 质量损失×1（IP-0642 ≤1.0→≤1 % 立码）+ 尺寸变化率×1（IP-0640
  ≤0.7 %，80℃,10d 立码）+ 表4 剥离强度×1（IP-0019 无处理 ≥1.5 N/mm；
  热处理/浸水 ≥1.2 变体挂账——conditions 非 PK 键维，禁条件注记进 spec
  维度，龄期裁定同族）+ 涂盖层厚度×1（IP-0646 ≥1.0→≥1 mm 立码）+ 闪点×1
  （IP-0421 ≥230 ℃）+ 搭接缝不透水×1（IP-0647 立码，三处理条件并 1 行——
  conditions 非 PK 键维裁定 2026-11-21）+ 6.4 总铅×1（IP-0645 ≤90 mg/kg
  立码，prose「不应大于」归一 ≤）。**文字面（eq 16 行）**：不透水×2（IP-0014
  spec 0.2/0.3 MPa、120 min）+ 耐热性×4（IP-0021 90/105/110/130℃ 无流淌无
  滴落）+ 低温柔性×4（IP-0022 -20/-25/-7/-15℃ 无裂缝；APP 7℃→-7℃ OCR
  负温号损形归一 MED）+ 热老化后低柔×4（IP-0013 -18/-23/-5/-13℃）+ 燃烧
  ×1（IP-0297 不低于 GB 8624 B2 级）+ 搭接缝×1。**立码+绑定面**：
  inspection_parameters.json +8（IP-0640~0647 sort_order 640~647，语义字典
  wp terms 不动——forward 前瞻词禁倒挂，wp 零卡模板，R13 brick 先例同形）+
  inspection_object_parameters.json +15（P10 junction 12→27：8 立码+IP-0021/
  0022/0044/0396/0059/0421/0297 补绑 7）+ inspection_standard_parameters.json
  +12（2025 8→20：IP-0013/0059/0421/0297 补绑 4+8 立码）+ standards 2008
  status→superseded。置信 HIGH×8+MED×30（符号归一/负温号损形/OCR 双碎片
  旗标逐行 remark 记）。选部（第二轮三候选并盘）：18242-2025 主候选胜出
  （wp 产品标限值面密集全 ≥/≤ 形、8 参已绑、tech-req 零行全开）。
  定性不导挂账（新增候选）：滑移 ≤2mm（语料缺值）、面积偏差 ±0.10（± 区间
  族挂账②）、人工气候加速老化现象面+≥80% 歧义碎片、剥离强度热处理/浸水
  变体、UI status 过滤面。验证链：dry-run 38/0/0→--write→守卫 10 it 先红后
  绿→旧钉 7 处一轮显形修毕→seeds 196/196→seed:db --reset+seed:check clean→
  DB 探针（38/0/superseded/8/27/20/9/581 全过）→双门全绿。兄弟仓同步清单：
  nextjs（守卫 tests/seeds/wp-r14-18242-techreq.test.ts 10 it+旧钉 7 处改钉，
  照单回放提交）。
- feat(seeds): **批R13——GB/T 5101-2017 烧结普通砖 + GB/T 11968-2020 蒸压加气混凝土砌块 双标同批 tech-req 首入库（③语料产线第 13 部，brick 砖砌块域回归 R5 后首次）**——
  inspection_technical_requirements.json +21 行（522→543）：5101 表3 强度
  等级×5——IP-0055 grade=MU30~MU10 平均值列 ≥30/25/20/15/10 MPa（fk 标准值
  列 22/18/14/10/6.5 单码双维挂账 13544 R5 先例同族；OCR 行无 ≥ 前缀由
  7.3.2/8.4.3 评定 prose 归一）+ 11968 表4 A 级×5——IP-0055 grade=A1.5~A5.0
  平均值列 ≥1.5/2.0/2.5/3.5/5.0 MPa（最小值列 1.2/1.7/2.1/3.0/4.2 挂账同族；
  A2.0/A2.5 OCR「>」由 8.2.3.2 判定 prose 归一 ≥）+ 表4 B 级干密度×5——
  IP-0189 grade=B03~B07 ≤350/450/550/650/750 kg/m³（OCR 符号损形：\350 缺符/
  《550 异形/750 缺符；B04/B05/B06 行内+独立行多重印证；B08 已随 2020 版删除
  不入面）+ 表6 导热系数×5——IP-0327 grade=B03~B07 ≤0.10/0.12/0.14/0.16/0.18
  W/(m·K)（pipe 层头行+值行直锚 HIGH×5，R12 表6 同形；B 级键同表4 干密度
  复用不撞 8 键 PK）+ §6.4 干燥收缩×1——IP-0639 grade='' ≤0.50 mm/m（text
  层行串锚 MED R11 形）。**人批三答（2026-11-20）**：双标同批 20 行+立码 1/
  §6.4 本批立码 IP-0639（junction+std-bind 同批补）/批准补绑定 P4×IP-0327
  （R12 表7 IP-0569 先例同形）。**立码+绑定面**：inspection_parameters.json
  +1（IP-0639 干燥收缩值 mm/m——字典原无精确参数，IP-0570 收缩率%≠干燥收缩值
  mm/m）+inspection_object_parameters.json +2（P4×IP-0327 补+P4×IP-0639 立
  码）+inspection_standard_parameters.json +1（11968×IP-0639）。置信面
  HIGH×5+MED×16（符号归一/副列挂账/符号损形/text 层锚旗标逐行 remark 记）。
  选部（三候选并盘 corpus-r13-scope.txt 317 块）：5101+11968 双标胜出（净面
  21 行+绑定链全）；GB 8076-2008 混凝土外加剂显式排除（表1 13 列宽变体矩阵
  OCR 列错位=账 74① 同族损形；表2/3/4 非限值面；附录A ±区间面——净面≈0）。
  定性不导（挂账面）：fk/最小值副列（单码双维族增 5101/11968 两标）、5101
  表4 抗风化 4 维交错粘连/表1 ±区间/表2 非限值面、11968 表5 抗冻损形/表3
  外观错位/表2 ±区间/表A.1 缺值、两标 prose 区零游离限值面。
  **挂账 75（2026-11-21 人裁两答）**：氯离子式(66)等化学面公式升 formula 型
  批——calc 84 行中 67 行 manual，GB/T 176 滴定/称重计算型公式只停 remark
  散文（IP-0004 氯离子式66 全条在 remark，algorithm_type=manual formula=null）
  → 运行时只消费 formula 型做跨参数求值，manual 回退通用采集卡直接输检测
  结果，采集→计算→评定链断在数据面（228.1 steel_tensile 引擎+1596 合成卡
  挂账 58 先例证明架构面已通）；立项第一步=GB/T 176 全公式面盘点清单（可
  DSL 表达/需新算法引擎/采集值立码清单三分）再人裁范围。
  验证链：抽取端锚自审计全绿（21 行/零拒收）→ 机械门 dry-run 21/0/0 → 种子
  护栏 186/186 → seed:db --reset+seed:check clean → DB 探针（21 行实值逐一
  吻合）→ 双门全绿。sync：nextjs（守卫 tests/seeds/brick-r13-5101-11968-
  techreq.test.ts 9 it+旧钉 ×8 处+CHANGELOG）。
- feat(seeds): **批R12——GB/T 25181-2019 预拌砂浆 tech-req 首入库（③语料产线第 12 部，mortar 砂浆域续作）**——
  inspection_technical_requirements.json +10 行（512→522）：表6 抗压强度 ×7——
  IP-0055 grade=M5/M7.5/M10/M15/M20/M25/M30（grade 字典 P8 七档原形，
  ≥5.0/7.5/10.0/15.0/20.0/25.0/30.0 MPa）+ 表7 抗渗压力 ×3——IP-0569
  grade=P6/P8/P10（≥0.6/0.8/1.0 MPa，P 级 grade 键照 GB/T 50082-2009
  IP-0190 grade=P6 先例），automatic，clause=表6/表7 pg10，双表双源
  source_hash；28d 固定龄期记 remark（IP 码=通用码，龄期进参数名=立码候选
  不属本批）。**人批补绑定（2026-11-20）**：IP-0569 junction（OBJ-SP01-P8）+
  std-bind（GB/T 25181-2019）两行同批落库——表7 原绑定双缺，绑定变更人批
  过闸（挂账面清偿非新增）。置信面 HIGH×10（表6/表7 pipe 层头行+值行直锚
  齐全，R11 MED 表头缺位反形）。选部（两候选并盘 corpus-r12-scope.txt 486
  块）：25181-2019 胜出；GB/T 15762-2020 显式排除（结构板承载面——承载力
  检验系数/破坏标志，IP 链无对应参数，配对损挂账 70 同族）。定性不导（挂账
  74）：表5/9/10/11/12 OCR 损形（值交错/错位/粘连——表9「≥12≥6」等，待
  原版 PDF 重摄解锁）、表8/13/14/15 ± 区间面（comparison 枚举无区间形）、
  表1-4 分类代号表、表16/17 出厂检验项目清单；prose 区零游离限值面
  （Step 1.7 盘点）。candidates 10 HIGH 0 MED 0 LOW
  （_work/import-r12-techreq.py；脚本 remark 尾逗号→单元素元组→JSON 数组化
  事故一回，回滚未提交行重抽修复——管线 skip 面 append-only 下先 checkout
  回滚再重写）。验证链：dry-run acceptedNew=10 → --write（回滚重写一次）→
  种子护栏 177/177 → 全量 1101|1sk → seed:db --reset+seed:check clean →
  DB 探针（10 行值面+双绑定）→ 双门全绿。sync 清单：nextjs（守卫+旧钉改钉
  ×6 处+CHANGELOG）。
- refactor(schema): **复验界面收敛批（共随 nextjs 批）——`-retest` 变体卡退役注释面
  同步（2026-11-20 人裁「界面列表冗余，收掉」）**——retest_mode=double 的数据录入
  语义改为解析器 config 深拷贝翻倍（table rows/series count ×2），4 张 `-retest`
  界面卡退役（在 nextjs 种子 34→30 行）；schema.ts `retest_mode` 列注释与
  tsp/models/sample-receipt.tsp 注释同步去 `-retest` 旧措辞（注释级，无 API 形状
  变更）。sync：nextjs（解析器重写+种子删卡+守卫+CHANGELOG）。
- feat(seeds): **批R11——JC/T 864-2023 聚合物乳液建筑防水涂料 tech-req 首入库（③语料产线第 11 部，wp 防水域续作）**——
  inspection_technical_requirements.json +6 行（506→512）：表1 三参数 ×T/G 两列——
  IP-0045 固体含量（≥65/≥60 %）、IP-0034 拉伸强度（≥1.2/≥2.0 MPa，拉伸性能
  （标准状态）组）、IP-0017 断裂伸长率（≥300/≥500 %）——model 键=T/G 型别
  （4.1.1 符号形，R10 model=PY 品种面同形），automatic，clause=表1 pg5，六行同源
  source_hash。**列身份证据链（整面 MED 旗标进 Step 5 人看闸）**：表1 列头行（T/G）
  语料缺失——列身份=4.1.1 行文序（通用型（T)在先）+注2 语义（高弹型→水性聚氨酯
  →高伸长 G 列自洽）双佐证、零矛盾（pipe 层无三参数值行，无 R10 式互斥指纹）；
  解锁=原版 PDF 表头重摄。**历史编号映射：本批无映射（R9/R10 反形再证）**——
  语料 standard_no=「JC/T 864-2023」=在册码原形（名称全等+active 双证，逐标实测
  禁沿用上批）。绑定面核证：IP-0045/0034/0017 junction 在+std 绑定在+unit 无分叉
  （%/MPa/%）；IP-0057 粘结强度 junction 在+std 绑定缺+行串位矛盾嫌疑（pipe
  「≥1.0标准状态/≥0.8潮湿基面」vs text 12 区「拉伸强度 ≥1.0 ≥2.0」）；IP-0018
  撕裂强度 std 绑定在+junction 缺（≥12/≥15 值面净——绑定变更人批）；IP-0025
  表干时间值面双缺（语料损）；IP-0041/0059 junction 缺；实干时间/加热伸缩率
  字典无码（立码候选）；IP-0074 密度「报告实测值」无限值（定性关闭）；表2 有害
  物质限量非对象检验参数面（定性关闭）。candidates 0 HIGH 6 MED 0 LOW
  （_work/import-r11-techreq.py）。选部（四候选并盘 corpus-r11-scope.txt 288 块）：
  864-2023 胜出；408-2005/326-2007/18173.4-2010 均值/标签交错损形不可导。
  净面 6 行 only——余面七项挂账 73。验证链：dry-run acceptedNew=6 → --write →
  seeds 170/170 → 全量 1093|1sk → seed:db --reset+seed:check clean → DB 探针 →
  双门全绿。sync 清单：nextjs（守卫+旧钉改钉+CHANGELOG）。

- feat(seeds): **批R10——GB 18243-2008 塑性体改性沥青防水卷材 tech-req 首入库（③语料产线第 10 部，wp 防水域首部）**——
  inspection_technical_requirements.json +3 行（503→506）：表2 可溶物含量厚度行族×3——
  IP-0009，spec 键=厚度 3mm/4mm/5mm（尺寸面，Φ 直径先例形），model 键=PY 胎基
  （水泥 P·O 品种先例形；PYG 列语料全「—」禁硬凑），min=2100/2900/3500 g/m²
  （automatic，clause=表2 pg5，三行同源 source_hash；5mm pipe 单层单证 MED 旗标进
  Step 5 人看闸——18242-2008 跨标同值核证，过门不改 verified）。**历史编号映射
  R9 反形**：语料 standard_no=「GB 18243-2008」（空格形）映射在册码「GB18243-2008」
  （无空格，消费面绑定与 object_standards JUDGMENT 行同形对齐），名称全等+active
  双证。**列身份矛盾指纹（账 72①）**：表2 pipe 层与 text 层同表互斥——pipe 不透水
  2 值 vs text 3 值「0.3/0.2/0.3」、pipe 耐热性 |—|110|130| vs text 三列语料不可证，
  18242-2008 跨标复现（|—|90|—| vs >90105）→ I/II×PYG 基本性能分档面整面阻塞
  （解锁=原版 PDF，13788 账 33 同族）；表义佐证=18242-2025 现行版同行「≥2 900
  可溶物含量/（g/m²） 4 mm」≥ 前缀。绑定面核证：IP-0009 junction 在（unit=% 与
  表2 g/m² 分叉入 remark 不改字典，账 46② 同族候选）；IP-0020 全库零绑定（表4
  搭接缝不透水净面惜失，绑定面变更人批——账 72⑤）；IP-0019 绑定在 unit=MPa 分叉。
  candidates 3 HIGH 1 MED 0 LOW（_work/import-r10-techreq.py）。净面 3 行 only——
  余面七项挂账 72。验证链：dry-run acceptedNew=3 → --write → seeds 165/165 →
  全量 → seed:db --reset+seed:check clean → DB 探针 → 双门全绿。sync 清单：
  nextjs（守卫+旧钉改钉+CHANGELOG）。

- feat(seeds): **批R9——GB 25779-2010 承重混凝土多孔砖 tech-req 首入库（③语料产线第 9 部，brick 域产品标第四部）**——
  inspection_technical_requirements.json +3 行（500→503）：表4 抗压强度平均值行×3——
  IP-0055，grade 键=MU25/20/15（175/R5/R6/R8 MU 先例），min=25/20/15 MPa
  （automatic，clause=表4 pg6，三行同源 source_hash）。**历史编号映射**：语料
  standard_no=「GB 25779-2010」（封面 GB 形）映射在册码「GB/T 25779 - 2010」
  （带空格）——judgment_standard_code 用在册码（消费面绑定与 object_standards
  JUDGMENT 行同形对齐），名称全等+active 双证，异形治理挂账 71⑥。锚纪律反形：
  25779 表4 det 框管道行**带**数据行（|MU15|15.0|12.0|，与 11945 表3 反形），
  文本框行双证同值；表头「单块最小值不小于」同 21144 词形；标题锚撞行坑
  （裸「抗冻性」撞表7 抽样数行→「表6#抗冻性」升级）。candidates 3 HIGH 0 MED 0 LOW
  （_work/import-r9-techreq.py，锚自审计 fail-fast 首跑拦 3 修锚后全绿）。净面
  3 行 only——余面十项挂账 71（单块最小值立码/碳化·孔洞率·外壁肋厚无码/软化·吸水·
  放射性未绑/表5 乱值/表6 抗冻空值/在册码异形/非参数面）。验证链：dry-run
  acceptedNew=3 → --write → seeds 159/159 → 全量 1082|1sk → seed:db --reset+
  seed:check clean → DB 探针 → 双门全绿。sync 清单：nextjs（守卫+旧钉四处改钉+
  CHANGELOG）。

- feat(seeds): **批R8——GB/T 11945-2019 蒸压灰砂实心砖和实心砌块 tech-req 首入库（③语料产线第 8 部，brick 域产品标第三部）**——
  inspection_technical_requirements.json +5 行（495→500）：表3 强度等级平均值行×5——
  IP-0055 抗压强度，grade 键=MU30/25/20/15/10（GB 175-2023/R5/R6 MU 先例），min=30/25/
  20/15/10 MPa（automatic，clause=表3 pg5，五行同源 source_hash；统计维（平均值）不入
  spec 键，11945 用词「单个最小值」≠21144「单块最小值」异形已核证入审计）。抽锚纪律
  新形状：11945 表3 det 框管道行无数据行（仅表头「| 抗压强度 |」），数据行全在 OCR
  文本框行——行锚=文本框行全串剥空白（MU30≥30.0≥25.5 形）块内/全语料双唯一命中，
  块标题锚+表头双证；candidates 5 HIGH 0 MED 0 LOW（_work/import-r8-techreq.py）。
  binding 面核证链：JUDGMENT 对象=OBJ-SP01-P4（P4 砖砌块瓦墙板链）；IP-0055 唯一绑；
  IP-0059 吸水率 junction 在未绑/IP-0578 软化系数在册未绑/碳化系数·干燥收缩率字典无码
  →净导入面=表3 五级行 only，其余八项挂账 69。语料 standard_no 与在册码同形（无历史
  编号映射）。验证链：dry-run acceptedNew=5 rejected=0 linkSkip=25 → --write → seeds
  153/153 → 全量 1076 passed|1 skipped → seed:db --reset+seed:check clean → DB 探针
  （11945×5 五级 ≥ 面/表3/pg5/total 500）→ 双门全绿。sync 清单：nextjs（守卫+旧钉
  四处改钉+CHANGELOG）。

- seeds(param-interfaces): **单值卡收敛批——20 张同构卡删废、links 收敛 default（2026-11-20 人裁）**——
  inspection_param_interfaces.json 54→34（20 张 rows=1 纯单值卡 [req_select,input] 两列
  删除；保留面=多行表 cement-setting-time/computed flyash-total·rebar-weight-deviation/
  专用卡；rebar-weight-deviation·flyash-total computed 列「检测结果 (%)」后缀剥除——
  单位改由渲染端注入）；inspection_param_interface_links.json 20 条
  param_interface_code 重指 default（51 条总量不变）。
  inspection_parameters.json IP-0202 静力受压弹性模量 unit 真数据 bug 随批修（%→MPa，
  行值面全 MPa）。消费端注入逻辑与守卫随批落 nextjs（sync 清单）。DB 探针四面全过
  （interfaces 34/links→default 20/单位后缀残留 0/IP-0202 MPa）→ seed:db --reset +
  seed:check clean。挂账不顺手做：**IP-0548 比表面积限值行错位**——水泥比表面积限值行
  挂在 IP-0217/0220 名下、IP-0548 名下零限值行（standard-gen 数据面，人批另批）；
  IP-0202/0638 零限值行由 nextjs p.unit 兜底面覆盖已闭环。

- seeds(param-interfaces): **参数界面文案统一「检验结果」→「检测结果」（2026-11-20 用户指令）**——
  inspection_param_interfaces.json 26 处换面（23 label + 3 description；version 不动，
  全局文案统一非形状换版；文件存量另 1 处「检测结果」本就在）。DB 探针 23 interfaces
  全换面零残留；守卫面（nextjs flat-card-table-form.test.ts 10 处改钉）随批；
  react/vue 等兄弟仓零落点。sync 清单：nextjs（守卫+CHANGELOG）。

- feat(seeds): **批R7——GB 50119-2013 混凝土外加剂应用技术规范 tech-req 首入库（③语料产线第 7 部，concrete 域立域批·人裁 2026-11-20）**——
  inspection_technical_requirements.json +4 行（491→495）：表7.3.1 掺引气剂或引气减水剂
  混凝土含气量限值×4——IP-0200 含气量，grade 键=粗骨料最大公称粒径分档
  10mm/15mm/20mm/25mm（grade 槽广义分档先例 1区/Ⅰ类/P6），max=7.0/6.0/5.5/5.0 %
  （正文 7.3.1「不宜超过」上限 ≤ 形走 max_value——R4 含水量 ≤1.0% 上限族形，
  automatic，clause=表7.3.1 pg27，sort_order 4334-4364 verified；四档值面零 OCR 反转）。
  行挂 OBJ-SP01-P5（检验对象=混凝土拌合物；IP-0200×P5/P6 junction 双在种子核证，
  P6 外加剂进场检验面不属本表语义）。立域面：nextjs semantic-dictionary.json 增
  concrete 域键（label 混凝土，terms 空数组照 soil/brick 先例零倒挂）——挂账 39
  （55008-2021 氯离子面）随之解锁。选部三分法三候选并盘（corpus-r7-scope.txt
  50119=349 块/JGJ52=77 块 + corpus-r7b-scope.txt 55008=249/8076=130 块）：
  55008 表面=结构配筋域+表3.1.8 行值配对 OCR 损（挂账 39 面）；8076 表1 受检混凝土
  性能指标（真限值面）OCR 全损不可复原——50119 净面最大胜出。抽取端锚纪律新形状：
  50119 表7.3.1 det 框管道行带数据行（异于 21144 文本框行——锚形状逐块实测定禁沿用），
  行锚=管道行全串剥空白块内/全语料双唯一命中，块标题锚+「粗骨料最大公称粒径」方向锚
  双证，限值列表头 OCR 错字「含汽量」锚避开，4 HIGH 0 MED 0 LOW，锚自审计 36 项全绿
  （_work/import-r7-techreq.py）。定性不导挂账 67 六项：①表7.3.1 粒径 40mm 行（OCR 值
  「1.5」不可靠——原 PDF 复核后可导，表注 C60 降幅 OCR 尾损「1，不低于3.5」同批复核）
  ②表13.3.1 限制膨胀率（IP-0199 双龄期维单码双维撞 8 键 PK 立码候选）③表8.4.2 硫酸钠
  掺量（IP-0215 含量语义漂移+环境/种类双条件维）④表13.3.6 灌浆用膨胀砂浆（扩展度/
  竖向膨胀率无在链码+OCR 列损）⑤表10.3.1/10.3.3 选择指南（区间值非判定限值+OCR 损）
  ⑥表13.5.3/表6.4.9（非检验参数）。sync 清单：消费仓零同步。验证链：机械门 dry-run
  acceptedNew=4 零拒收（linkSkip=24 三键全在）→ --write 108 行=4 行自洽 → 守卫
  admixture-app-50119-techreq.test.ts 6 it（种子 append 前天然真红——gate --only L4
  红证据 09:25:25 落 .state/red.json，phase.py 正门出红区；R6 遗留 red 区同批清偿）
  → 旧钉随批改钉（总数 491→495：cement-surface +countFor 50119=4；rebar-surface
  495/-82+50119 跳过面+零漂移滤出+rebarStds 面；age-param-migration 不触零改）
  → seeds 组 147/147 → seed:db --reset + seed:check clean → DB 探针 4 行实值全对
  total 495（comparison/expression hex 回验 e289a4=≤）→ 双门全绿。

- feat(seeds): **批R6——GB/T 21144-2023 混凝土实心砖 tech-req 首入库（③语料产线第 6 部，brick 域产品标第二部）**——
  inspection_technical_requirements.json +8 行（483→491）：表4 强度等级平均值行×8——
  IP-0055 抗压强度，grade 键=MU40/MU35/MU30/MU25/MU20/MU15/MU10/MU7.5（GB 175-2023/
  批R5 13544 强度等级键先例），min=40/35/30/25/20/15/10/7.5 MPa（comparison ≥，
  automatic，clause=表4 pg6，sort_order 4254-4324 verified；八级值面零 OCR 反转）。
  同表行单块最小值（35/30/26/21/16/12/8/6）不属本批：单码双维撞 8 键 PK——立码候选
  （同 13544 fk 形，挂账 66①，13544 fk 立码人批后随批）。抽取端锚纪律新形状：
  21144 表4 det 框管道行无数据行（仅表头），数据行全在 OCR 文本框行——行锚=文本框行
  全串剥空白（「MU40≥40.0≥35.0」族），块标题锚+表头「平均值/单块最小值」双证，
  8 HIGH 0 MED 0 LOW，锚自审计 32 项全绿（_work/import-r6-techreq.py；junction 种子
  双面核证：IP-0055×P4 在/IP-0074×P4 缺）。定性不导挂账 66 八项：①单块最小值立码候选
  ②碳化系数 ≥0.85（字典无码）③软化系数 ≥0.85（IP-0578 在册未绑 21144）④放射性
  IP-0062 未绑（13544 同款）⑤表3 密度等级（IP-0074 绑 21144 但不在 P4 对象链+OCR 丢级名）
  ⑥表5 吸水率（IP-0059 未绑+B 级 OCR 反转+C 级 < 归一）⑦表6 干燥收缩 OCR 乱
  ⑧表7 抗冻性（码不在链+F 分档）。语料 standard_no 与在册码同形（无 13544 式映射）。
  sync 清单：消费仓零同步。验证链：机械门 dry-run acceptedNew=8 零拒收（linkSkip=23
  三键全在）→ --write 216 行=8 行自洽 → 守卫 concrete-brick-21144-techreq.test.ts 6 it
  （红证据 08:37:06 levels=[L4] stash 取证正门消费）→ 旧钉随批改钉（总数 483→491：
  cement/rebar surface + age-param-migration IP-0055 他标计数 6→14 第六处）→
  seeds 组 141/141 → seed:db --reset + seed:check clean（dedupe dropped 2 已知账 44）→
  DB 探针 8 行实值全对 total 491（expression/comparison hex 回验 e289a5=≥）→ 双门全绿。

- feat(seeds): **批R5——GB/T 13544-2011 烧结多孔砖和多孔砌块 tech-req 首入库（③语料产线第 5 部，brick 域产品标首部）**——
  inspection_technical_requirements.json +5 行（478→483）：表4 强度等级平均值行×5——
  IP-0055 抗压强度，grade 键=MU30/MU25/MU20/MU15/MU10（GB 175-2023 grade=42.5 强度等级
  键先例），min=30.0/25.0/20.0/15.0/10.0 MPa（comparison ≥，automatic，clause=表4 pg5，
  OCR「30. 0」小数点后空格归一）。同表行强度标准值 fk（22.0/18.0/14.0/10.0/6.5）不属本批：
  单码双维撞 8 键 PK——立码「抗压强度标准值」人批候选（175 龄期进参数名先例，挂账 65①）。
  语料编号 GB 13544-2011→在册码 GB/T 13544-2011 映射在锚审计钉死（第 5 章强制性条款历史编号）。
  抽取端锚纪律：禁 clause_id 直取——表4 块标题锚+行全串剥空白唯一命中+表头「抗压强度平均值/
  强度标准值」双列方向锚，5 HIGH 0 MED 0 LOW，锚自审计 26 项全绿（_work/import-r5-techreq.py，
  首次带 junction 种子核证：IP-0055×P4 在/IP-0062×P4 缺双面核证）。定性不导挂账 65：
  fk 立码候选、calc 式(1) OCR 碎/式(2) 依赖立码、放射性 junction 缺、表6 抗风化 OCR 损
  （IP-0059 在链）、表3 密度 OCR 损+区间值（IP-0189 在链）、表1 尺寸偏差码不在链、
  表5 孔洞率码不在链、泛霜/石灰爆裂/冻融 prose 定性面。sync 清单：消费仓零同步。
  验证链：机械门 dry-run acceptedNew=5 零拒收（挂链三键全在 linkSkip=22）→ --write →
  守卫 brick-13544-techreq.test.ts 6 it（红证据 22:30:18 levels=[L4] stash 取证正门消费）
  → 旧钉随批改钉（总数 478→483：cement/rebar surface + age-param-migration IP-0055
  他标计数 1→6 第五处，同 stash 轮红证据）→ seeds 组 135/135 → seed:db --reset +
  seed:check clean → DB 探针 5 行实值全对 total 483 → 双门全绿。

- feat(seeds): **批R4——GB/T 18046-2017 粒化高炉矿渣粉 tech-req 首入库（③语料产线第 4 部）**——
  inspection_technical_requirements.json +5 行（473→478）：表1 全级别单值行——流动度比
  IP-0222 ≥95 % / 含水量 IP-0565 ≤1.0 %（表值「\1.0」≤ OCR 破损归一，枚举无 <，GB 175 先例）/
  三氧化硫 IP-0008 ≤4.0 % / 烧失量 IP-0218 ≤1.0 %（前言双证 3.0→1.0 升版注记）/ 放射性
  IP-0062 IRa·Iγ ≤1.0（string/expression 合一单行，照 GB 175-2023 族形，语料「I」按 GB 6566
  归一 Iγ）；8 键哨兵全 ''（表1 五行全级别统一 S75/S95/S105 无分档值）。抽取端锚纪律：禁
  clause_id 直取——表行全串文本双证（表1 块标题锚+行串剥空白唯一命中），5 HIGH 0 MED 0 LOW，
  锚自审计 24 项全绿（_work/import-r4-techreq.py）。定性不导挂账 64：比表面积/活性指数
  per-grade 表行错位（IP-0220/IP-0221 在链）、密度/初凝时间比/玻璃体/不溶物码不在 P7 链、
  氯离子表值「90°0」OCR 反转不可靠、calc 候选面附录A 式A.1-A.4+附录B 式B.1+6.6 烧失量
  校正式(1)(2)。sync 清单：消费仓零同步（tech-req 种子消费面 nextjs 单仓先行，批60① 先例）。
  验证链：机械门 dry-run acceptedNew=5 零拒收（挂链三键全在 linkSkip=21）→ --write →
  守卫 slag-18046-techreq.test.ts 8 it（红证据 22:03:42 levels=[L4] stash 取证正门消费）
  → seed:db --reset + seed:check clean → DB 探针 5 行实值全对 → 旧钉随批改钉（tech-req
  总数 473→478：rebar/cement surface-import + cement countFor 18046=5 + rebar 跳过面/
  零漂移滤出面，红证据 22:05:00）→ seeds 组 129/129 → 双门全绿。

- feat(seeds): **批21372——GB/T 21372-2024 硅酸盐水泥熟料 tech-req 首入库（③语料 57 部产线首部）**——
  inspection_technical_requirements.json +3 行（470→473）：5.2.1.1 凝结时间 IP-0550 ≥45 min /
  IP-0551 ≤390 min（numeric automatic，全品种单行）+ 5.2.1.2 沸煮安定性 IP-0002 eq/string
  目标值「合格」（照 JC/T 600-2010 行形）；8 键哨兵全 ''（21372 技术要求全品种统一无品种
  维度，GB 175 per-variety model 行形不适用，scoping 已裁）。抽取端锚纪律：禁 clause_id
  直取——文本双证（5.2.1.1 prose 全句锚+45/390 数值形状唯一命中；5.2.1.2 标题+正文双证），
  3 HIGH 0 MED 0 LOW，锚自审计 22 项全绿（_work/import-21372-techreq.py）。定性不导挂账：
  表1/2/3 OCR 错位（RA-21372-1）、6.1.3 矿物组成式(1)-(5)+四码立码、水化热（表4）、7d 抗压、
  线膨胀率（GB/T 749 不在册）、放射性指数、方法标 749/750/12959/31893 立册；5.4/5.5 选择性
  指标（商定）、6.2.2 制样细度（工序面）不导。sync 清单：消费仓零同步（tech-req 种子消费面
  nextjs 单仓先行，批60① 先例）。验证链：机械门 dry-run acceptedNew=3 零拒收 → --write →
  守卫 clinker-21372-techreq.test.ts 6 it（红证据 20:51:06 levels=[L4] stash 取证正门消费）
  → seed:db --reset + seed:check clean → DB 探针 3 行实值全对 → 旧钉随批改钉 3 处（tech-req
  总数 470→473：rebar/cement surface-import + cement countFor 21372=3，红证据 20:56:42）
  → seeds 组 121/121 → 双门全绿。

- feat(seeds): **挂账 58——IP-0568 总量行 formula 型 + 合成卡 v2（2026-11-19 人批三决定）**——
  inspection_calculation_methods.json IP-0568（OBJ-SP01-P7，GB/T 1596-2017 7.3 三输入
  合成）algorithm_type manual→formula、formula=`IP-0621 + IP-0622 + IP-0623`（ident 键=
  IP 码直做，人裁 ①）、remark 尾段转接线收口注记；inspection_param_interfaces.json
  flyash-total-silica-alumina-iron v1→v2：values 手输列退役 → total 列 mode=computed
  algorithm=formula + config.computed 接线（label「总量合成 (%)」）。消费仓 nextjs 运行时
  求值接线同 commit 批（REGISTRY formula 项，人裁 ②③——合成格只读自动算），契约枚举
  CalculationAlgorithmType 零改动（formula 已在册）。sync 清单：react/vue/aspnetcore/
  springboot/rails/fastapi/kotlin/laravel/go 等消费仓本批零同步（种子消费面在 nextjs
  单仓先行先例同批60①③）。验证链：seeds 组 115/115 → seed:db --reset + seed:check
  clean → DB 探针 → 双门全绿（shared L5 零挂）。

- fix(seeds): **批60③——FM 粉煤灰样品三维修正（账 60③，2026-11-19 人批队列）**——
  samples.json SAMPLE-FM-0141~0147（委托 RN-107-2 判定依据 GB/T 1596-2017）三维
  model/grade/specification 由空/「标准试样」对齐字典四码表与 1596 tech-req 实际
  组合面：表1 拌制用全矩阵 6 样品（F/C 类 × Ⅰ/Ⅱ/Ⅲ级）+ 表2 混合材用 1 样品
  （F类/grade 空通配）——EntryModal 技术要求维度过滤（行维度非空即须与样品一致）
  reqOptions 由空转可达，1596 录入即验收层3 端到端缺口关闭。验证链：守卫红
  （fm-sample-dimensions 2 it，红证据 19:40:25 levels=[L4]）→ 出红 → 种子改 7 行 →
  seeds 组 107/107 → seed:db --reset + seed:check clean → DB 探针（141~147+sso
  镜像全带新三维）→ 双门全绿。

- feat(seeds): **批60①——粉煤灰 8 + 水泥 7 参数界面补卡（账 60①，2026-11-19 人批队列）**——
  inspection_param_interfaces.json 39→54 / inspection_param_interface_links.json 36→51：
  粉煤灰 8 参数（IP-0549/0219/0221/0565/0568/0403/0074/0637，1596 判定核验收层2 缺口
  ——零卡走 GenericParamCard 回退无判定路径）+ 水泥 7 参数（IP-0006/0548/0550/0551/
  0552/0553/0638，含批54 新码标准稠度用水量）各 15 卡 15 link。形状=cement-so3 表格卡
  先例：rows=1 + 技术要求(req_select)/检验结果(unit)(input) 两列，version 1，
  description 记标准条款与公式转录挂账态；凝结/安定性分列码 description 记批54 人裁
  口径（判定分列/方法合并——方法面 IP-0001 一行）。公式面统一 manual+挂账（转 formula
  另批照挂账 58 办）。验证链：守卫红（红证据 19:29:16 levels=[L4]）→ 出红 → 生成器
  幂等落库 → seeds 组 105/105 → seed:db --reset + seed:check clean → DB 探针
  （54 卡/51 link，15 卡 v1 全入库）→ 双门全绿。

- feat(seeds): **批57——spec 字典粉煤灰用途二值供货（账 57②）**——
  inspection_specs.json 66→68：P7（粉煤灰）+2 行「拌制砂浆和混凝土用」/「水泥活性
  混合材料用」（SP-OBJ-SP01-P7- 前缀，sort 1/2，source 记 GB/T 1596-2017 表1/表2
  用途）——manifest 按需供货走 specimen-config:import 管线（dry-run append=2 零旗标，
  append 通道不停人），1596 tech-req 29 行 spec 维度消费闭环。守卫：specimen-config
  加 P7=2 钉；seed:db --reset + seed:check clean → DB 探针 → 双门全绿。

- feat(seeds): **批54——GB/T 1346-2024 标准稠度用水量立码 IP-0638（账 54①，2026-11-19 人批队列）**——
  四面落库零删行：字典 +1（IP-0638，sort 638，unit %，method_text「按 GB/T 1346-2024」）+
  1346 挂链 +1（档 2→3）+ P1 junction +1（QUALIFIED，记录值参数）+ calc +3 manual 行
  （sort 130/140/150：8.3 试杆法基准法 P=mw/mc×100% / 9.3.3 调整水量法 30mm±1mm /
  9.3.4 不变水量式(1) P=33.4−0.185S，公式面全 remark LaTeX，挂账 58 接线时升级 formula 型）。
  calc 变体面同 IP-0006×176 先例：种子 3 行、DB PK 三键存活 1 行（8.3 主方法）。
  **账 54② 口径定谳（2026-11-19 人裁）：凝结时间判定分列（IP-0550/0551）/方法合并
  （IP-0001）——1346 不加分列 calc 行；JC/T 600 迁移欠条另批照此口径办。**
  验证链：守卫天然红 3（红证据 19:00:31）→ 出红 → 落库（生成器幂等，calc created_at
  漏键事故在案：首写 3 行无时间戳被 seed:db NOT NULL 拦下，git checkout 回 calc 单文件
  修复重落）→ 护栏改钉再红一轮正门（stash 回 HEAD 取真红，证据 19:04:24）→ 102/102 →
  seed:db --reset + seed:check clean → DB 探针 → 双门全绿。

- fix(seeds): **账 59——IP-0006 式(39) n2 注记修正（批CE4 转录错误，2026-11-19 人批）**——
  inspection_calculation_methods.json IP-0006（氧化镁，GB/T 176-2025 基准法）remark
  小段「（无分取时 n2=1）」→「（分取溶液体积无改变时按 n2=50 计算，如 250 mL 定容
  分取 5 mL）」——语料 6.11.3 符号释义原文「如分取溶液体积无改变按照 n2=50 计算」，
  「无改变」误读成「无分取」且数值 50→1。守卫先红正门（cement-surface-import 账 59
  describe 2 it，红证据 18:35:55）→ 种子修正 → 330/330 → seed:db --reset +
  seed:check clean → DB 探针 → 双门全绿。

- feat(seeds): **批CE8——176 化学分析 16 码 31 式 calc 转录 + IP-0568 合成行（账 1 收口，2026-11-19）**——
  inspection_calculation_methods.json +17 行（64→81，全 manual/formula=null/LaTeX 进
  remark/sort 125）：GB/T 176-2025 ×16（IP-0621~0636，基准法+代用法双面 31 式，
  逐式锚条款号+式号+dfrac 公式，总 dfrac=30）+ GB/T 1596-2017 IP-0568 总量三输入
  合成行（P1→P7 域，7.3 锚，SO3+不溶物+烧失量按 IP-0621/0622/0623 相加，测法争议
  以硫酸铜返滴定为准进 remark）。MED 旗标 2 处（处置=批立项人批方案，依据进
  remark）：IP-0623 式(37) OCR 减号缺失按 6.9.1 prose 归一为减号；IP-0627 式(69)
  OCR 分数线破碎按式(68) 平行同构复原。inspection_object_standards.json +1
  （OBJ-SP01-P7 × GB/T 1596-2017 TESTING，199→200，CE7 tech-req+本批试验 calc 行
  =真双链，白名单挂法同 JGJ 107-2016 先例）。验证链：守卫先行真红（evidence
  16:51:40）→ WRITE acceptedNew=17 rejected=0 medCount=2 → 护栏 97/97 →
  seed:db --reset + seed:check clean → DB 探针全中 → 双门全绿。挂账：formula 型
  运行时求值接线（58）/IP-0006 n2 注记出入（59）。
- feat(seeds): **批CE7——GB/T 1596-2017 tech-req 限值导面（账 56，2026-11-19 人看闸四处照判读+spec 维度照收口）**——
  inspection_technical_requirements.json +29 行（441→470，全 verified/automatic，
  source_hash=sha256 证据文本前 16 位十六进制）：表1 拌制砂浆和混凝土用 ×18（spec=
  「拌制砂浆和混凝土用」——细度 IP-0549 Ⅰ≤12.0/Ⅱ≤30.0/Ⅲ≤45.0、需水量比 IP-0219
  Ⅰ≤95/Ⅱ≤105/Ⅲ≤115、烧失量 IP-0218 Ⅰ≤5.0/Ⅱ≤8.0/Ⅲ≤10.0、含水量 IP-0565 ≤1.0
  （< 归一 ≤）、SO3 IP-0008 ≤3.0、游离钙 IP-0403 F≤1.0/C≤4.0、总量 IP-0568
  F≥70.0/C≥50.0、密度 IP-0074 C类≤2.6 g/cm³、安定性 IP-0002 C类≤5.0mm、活性指数
  IP-0221 ≥70.0）；表2 水泥活性混合材料用 ×10（烧失量 ≤8.0/含水量 ≤1.0/SO3 ≤3.5/
  游离钙同表1/总量同表1/密度 ≤2.6 全类/活性指数 ≥70.0/安定性 C类≤5.0）；6.4
  prose ×1（IP-0637 半水亚硫酸钙 ≤3.0%，conditions=干法或半干法脱硫工艺排出灰）。
  **维度设计**：品种→model（F类/C类，字典现行值）、等级→grade（Ⅰ/Ⅱ/Ⅲ 罗马字符）、
  用途→spec（4.2 实文二值）——spec 维度是表1 SO3 ≤3.0 vs 表2 ≤3.5 同键必撞的解法；
  同值跨 F/C 格子忠实转 model='' 不逐类展开。OCR 矩阵判读真源
  `_work/ce6-techreq-matrix.md`（29 行逐格锚注，6 MED 全 remark 旗标，人看闸
  2026-11-19 四值照判读收口：需水量比Ⅰ级95/烧失量Ⅰ级5.0/密度C类适用面+unit 分歧/
  表2 安定性5.0）。不导面：放射性（6.2 无数值）/碱含量（6.3 协商）/均匀性（6.5
  协商）/氯离子（1596 无此要求）。挂账：选择器 label 不含维度（溯源可辨性）、spec
  字典二值待 Step 4.5 按需供货。验证链：守卫先行真红（evidence 14:48:31，红线复演
  再证 14:55:30/15:00:29）→ 管线 WRITE acceptedNew=29 rejected=0 → 护栏 92/92 →
  seed:db --reset + seed:check clean → DB 探针全中（18/10/1 分流+SO3 按 spec+细度
  三级）→ 双门全绿。
- feat(seeds): **批CE6——GB/T 1596-2017 粉煤灰链面批（挂账 55，2026-11-19 人批四裁定全推荐项）**——
  inspection_parameters.json 字典 +1（IP-0637 半水亚硫酸钙含量，method_text
  「按 GB/T 5484」库外标注记，sort 637，全文件 635→636）；
  inspection_standard_parameters.json 挂链 +7（GB/T 1596-2017 × IP-0568 总量/
  IP-0008 SO3/IP-0403 游离钙/IP-0565 含水量/IP-0549 细度45μm/IP-0221 活性指数/
  IP-0637，1596 档 8→15，全文件 530→537）；inspection_object_parameters.json
  junction +5（OBJ-SP01-P7 × IP-0568/0403/0565/0549/0637 全 QUALIFIED——1596
  表1（续）/表2/6.4 均有真限值行，remark 记条款与限值，全文件 897→902）。
  **IP-0568「总量」真源实锚**：表1（续）/表2 F≥70.0/C≥50.0，试验方法 7.3 按
  GB/T 176 三组分相加——批CE5 新码 IP-0621/0622/0623 即三输入，CE5「转账 1596」
  账面闭环（calc 合成行归账 1 另批）。细度挂 IP-0549 专项码（7.1 条款自证，
  2026-11-19 人裁）；IP-0221 活性指数直接挂（calc/tech-req 面届时核语义）；
  均匀性（6.5）定性不立码（以细度最大偏差表征）；tech-req 表1/表2 限值导面
  （F/C×I/II/III 矩阵）另批。验证链：守卫先行真红（7 用例，evidence 13:15:33）
  → 种子三面 → 全量 995 过 → seed:db --reset + seed:check clean → DB 探针全中
  → 双门全绿。同步：nextjs 守卫两文件钉值（636/537/CE6 describe 三用例）。

- feat(seeds): **批CE5——176 化学分析未立码 16 参数族立码（挂账 53②③，2026-11-19 人批）**——
  inspection_parameters.json 字典 +16（IP-0621~0636 连号，sort_order==code 数字
  全字典零例外口径，名称「X含量」形/method_text「见对应标准条款」/unit %；
  二氧化硅/三氧化二铁/三氧化二铝/氧化钙/二氧化钛/氧化钾/氧化钠/硫化物硫/
  一氧化锰/五氧化二磷/二氧化碳/氧化锌/氟离子/水溶性氧化钾/水溶性氧化钠/
  水溶性碱——GB/T 176-2025 式(33)-(53) 结果参数族）；inspection_standard_parameters.json
  挂链 +16（176 档 7→23，全文件 514→530）；inspection_object_parameters.json
  junction +16（OBJ-SP01-P1 全 RESTRICTED，remark 逐码记公式条款号，全文件 881→897）。
  ② IP-0568（SiO2+Al2O3+Fe2O3 总量）定性**不导 176**——176 语料无「总量」条款
  （三组分各自式(35)/(36)/(37)），其真源=GB/T 1596 粉煤灰（method_text 自证），
  转账 1596 链批（HISTORY 挂账新条）；③ calc 公式转录不在本批（挂账 1 长CJK
  坏写防线，另批）；XRF 熔片族 式(81)-(92) 定性工具面不导（同批CE3 试剂标定逻辑）。
  验证链：守卫先红（10 用例断言红，evidence 11:02:39）→ 种子三面 → 守卫+全量
  992 过 → seed:db --reset 重浇 + seed:check clean → DB 探针 16/16/16 全中 →
  双门全绿。同步：nextjs 守卫两文件钉值（635/530/176档23/16码形状）。

- feat(seeds): **默认兜底卡表格化+更名（2026-11-19 用户裁定）**——
  inspection_param_interfaces.json code=default v1→2：「默认四格卡」→「默认卡」，
  config 四格（requirement/result textarea）→单行表格（技术要求 req_select +
  检验结果 input，通用兜底无域单位故检验结果不带后缀；showLabel false）；
  description 注记四格退役。表格化批护栏 tests/seeds/flat-card-table-form.test.ts
  末位追钉 default 用例（前批「default 兜底卡除外」清单随之收口）。三处测试
  内旧名引用同步更名（mock fixture/注释，receipts/data-entry）。

- feat(seeds): **批CE4——GB/T 176-2025 化学成分已立码三件收口（挂账 53①，2026-11-19 人批）**——
  inspection_calculation_methods.json +3（OBJ-SP01-P1 × 176-2025：IP-0006 氧化镁
  式(39)原子吸收基准/式(61)(62)EDTA 差减两分支 + IP-0385 不溶物式(32) +
  IP-0403 游离钙式(75)-(78)四代用法，均 manual、公式 LaTeX 进 remark，
  sort 113-115，全文件 61→64）；inspection_standard_parameters.json 挂链 +3
  （176 × IP-0006/0385/0403，档 4→7）；inspection_object_parameters.json junction
  +2（P1 × IP-0385 RESTRICTED（GB 175 限值 ≤0.75/1.5）/ IP-0403 QUALIFIED（无限值））。
  转义指纹在册：`10^6` 经占位符替换被吞成 `10\6`，repr 回验抓到后定点修复——
  LaTeX 上标 `^` 禁走占位符替换面。nextjs 同步：calc 护栏 61→64、挂链双守卫
  511→514（cement/rebar surface-import）。双门全绿（nextjs+shared EXIT=0）。

- feat(seeds): **UI 表格化改造批——参数界面七卡平铺→表格（2026-11-18 用户图示+裁定两则）**——
  inspection_param_interfaces.json 七卡 version 1→2：①cement-setting-time v2 表格
  （rows=2，列 初凝/标准要求/终凝/标准要求 (min)，req_select 逐行标准要求下拉，
  图示表头「凝结时间(min)」形状）；②六张单值卡（cement-chloride/alkali/so3/
  loss-on-ignition、concrete-elastic-modulus、soil-optimum-moisture）v2 表格 rows=1
  （技术要求 req_select + 检验结果 (单位) input）。裁定在案：评定列不做（GB 175
  氯离子行 max=null 技术要求面未拆，机判不成立——评定保留卡头右上角）；
  IP-0550/0551 初凝/终凝绑定拆分（机判拆分）另批；已有表格卡（soundness/fineness）
  未加 req 列属候选扩面。护栏测试随 nextjs 同批（flat-card-table-form）；
  seed:db/--reset 已浇 + seed:check clean + 双门全绿。
- fix(seeds): **参数去重批——RN 关联删四行通用/误挂码（2026-11-18 人裁两则）**——
  inspection_report_name_parameters.json 260→256 行：①RN-101 删 IP-0001（凝结时间·通用）/
  IP-0002（安定性·通用）——保留 specific 码 IP-0550/0551（初凝/终凝）、IP-0552/0553
  （沸煮法/压蒸法），用户裁定「保留带括号细分、删通用」；②RN-105-3（混凝土拌合用水）删
  IP-0004（氯离子·通用）——specific IP-0580（氯离子（拌合用水））是正主；③RN-110-1
  （防水卷材）删 IP-0044（延伸率·通用）——specific IP-0011 是正主。判定链源头核实：
  RN-105-3 三标准 tech_req 只挂 IP-0055（1 行）、RN-110-1 九标准零 tech_req——删除不孤立
  任何限值；RN-101×IP-0004（水泥氯离子，GB 175/3183/2015 限值在）保留不动。
  specific 码 interface link 缺面在案（水泥初凝/终凝/沸煮/压蒸四码现走通用采集卡回退，
  卡形状改造归 UI 表格化批另议），param-interface-link-coverage T1 钉的 IP-0001/IP-0002
  link 面未动。DB 面 --reset 重浇（常规浇不删行、seed:check 陈旧 4 行红→收口），
  seed:check clean + 探针 0 行余留 + 双门全绿。测试面零断言扰动（receiptFormParamFilter
  「17 项」仅注释随批校正为 14）。
- fix(seeds): **账 44 人裁收口——calc 228.1 双胞胎变体行删 null 孪生（2026-11-18）**——
  (OBJ-SP01-P2, IP-0086/0087, GB/T 228.1-2021) 各两行孪生（RN-102-2 vs null 报告名、
  remark JGJ 107 尾注、sort 异），灌库 dedupe（非空字段数多者胜）各丢 1 → seeds≠DB。
  人裁留 RN-102-2 行（现行行胜先例同向），删 null 孪生两行 → 63→61 行，dedupe 零丢，
  种子↔DB 全等面恢复。DB 实面零变化（被丢行本不在库）。护栏镜像随 nextjs 同批
  （calc-method-formula 2b 63→61/P2 15→13、consistency 锚 IP-0087 sort4→16、
  calc-method-gate steel_tensile ≥4→≥3）。
- refactor(contract): **tech_req DTO 摘 tenantId（2026-11-18 人裁账 49：tech_req 归全局共享、
  DB 无 tenant_id 列，契约面同步删字段）**——tsp/models/technical-requirement.tsp
  TechnicalRequirement 删 `tenantId: string`（含人裁注记，对照 2026-11-09 schema.ts:44-47）；
  generated/openapi/openapi.yaml required 列表+properties 同步（emit 重浇，仅该 model 三行）。
  本批范围=shared+nextjs（人裁）：nextjs gen-shared 重浇生成物+marker 刷至本 commit，
  两 dom 测试摘 tenantId 注水。**其余五后端现状留档暂不动**（fastapi/django/rails/go 落 ''
  占位、aspnetcore Generated 属性 null、spring 已摘字段——gen-shared 重浇时各自收链，
  详见 suite standard-gen HISTORY 挂账 49）。
- feat(seeds): **批M 砂浆域立域批——mortar 域键+锚五件+70-2009 calc 十一行导入（2026-11-18，五域大批次第五域收官）**——
  seeds 面两处：① inspection_calculation_methods.json +11（52→63 行），全
  algorithm_type=manual、formula=null 的 prose 计算面（公式 LaTeX 入 remark）：
  OBJ-SP01-P8 + OBJ-SP07-P13 × JGJ/T 70-2009 各 4（IP-0055 立方体抗压
  $f_{cu}=K\times N_u/A$——式体 OCR 塌缩按符号族面唯一复原、remark 明示，
  9.0.5 三试件平均超 15% 取中值入 conditions，修约 0.1 MPa / IP-0001×8.0.5
  贯入阻力 $f=N_p/A_s$ 与×8.0.6 凝结时间两试样平均 ≤30min / IP-0225×6.0.4
  分层度前后稠度之差 / IP-0223×4.0.4 稠度两次平均——后三者修约 1mm）+
  OBJ-SP05-P1/P4/P5 × 70-2009 各 1（IP-0296 拉伸粘结 $f_{at}=F/A$，10.0.8
  十试件平均 20% 逐次剔除有效≥6 入 conditions，修约 0.01 MPa）；修约枚举
  新增「修约到 0.1 MPa」「修约到 1mm」。② inspection_object_standards.json
  +4（195→199 行）：TESTING 机械补链（SP07-P13、SP05-P1/P4/P5 × 70-2009），
  judgment-link-snapshot 钉值 195→199 随批改。**判重键裁定**：calcMethodKey
  两键（param|std）实现漂移修正为三键（obj|param|std）对齐 DB PK——同参同标
  不同对象行（P8+SP07-P13 首撞）不再误判 skip；现行两键双占仅账 44 双胞胎
  （三键 PK 下合法多对象行）零扰动。零硬凑面（保水率式体孤「1」/抹灰·砌筑
  拉伸粘结挂链缺/表观密度 junction 缺/抗渗 PH0.1 双解/抗冻·收缩·含气量·
  吸水率·轴压链缺/SL/T 352-2020 语料不在库）→ HISTORY 账 48；批AD 零导面
  定性→账 47。域面/锚面在 nextjs 仓（同批提交）：semantic-dictionary.json
  增 mortar 域；standard-extract-anchors.json 增 mortar 五锚。
- feat(seeds): **批WP 防水域立域批——wp 域键+锚五件+16777/328.8 calc 五行导入（2026-11-18，五域大批次第三域）**——
  seeds 面一处：inspection_calculation_methods.json +5（52 行）：OBJ-SP01-P10-防水涂料 ×
  GB/T 16777-2008×3（IP-0045 固体含量 X=(m2−m0)/(m1−m0)×100——式体 OCR 塌缩按 5.2
  步骤+式中符号面转写、remark 明示，修约 1% / IP-0057 粘结强度 σ=F/(a×b) ≥3 试件
  平均修约 0.01 MPa / IP-0034 拉伸强度 T=P/(B×D) 5 试件平均修约 0.01 MPa）+
  OBJ-SP01-P10-防水卷材 × GB/T 328.8-2007×2（IP-0010 拉力 5 试件平均修约 5N /
  IP-0011 延伸率平均修约 1%——均 prose 计算面 manual 无公式体），algorithm_type=
  manual 全族，remark 逐行人工判读描述。挂链零新增（P10 三对象×TESTING 七标先前
  已在；两标全在 method 40 集）。零硬凑面（式(4) 公式体丢失/式(5)(7) 参数未立码/
  撕裂·剥离单位分叉/328.26 M 系符号面丢失）→ HISTORY 账 46。域面/锚面在 nextjs 仓
  （同批提交）：semantic-dictionary.json 增 wp 域（label 防水材料，terms 空数组
  起步）；standard-extract-anchors.json 增 wp 五锚（solid-content/bond-strength/
  tensile-strength/tensile-force-avg/elongation-avg，clauseKind=clause）。
- feat(seeds): **批B 砖砌块域立域批——brick 域键+锚六件+三方法标 calc 十行导入（2026-11-18，覆盖推进第 6 批）**——
  seeds 面一处：inspection_calculation_methods.json +10（47 行）：OBJ-SP01-P4 ×
  GB/T 11969-2020×4（IP-0189 干密度 ρ0=M0/V×10⁶ 修约 1 kg/m³（语料 kg/m² OCR
  误置注记归一）/ IP-0055 抗压 fcc=P1/A1 修约 0.1 MPa / IP-0056 抗折
  ff=PL/(bh²) 修约 0.01 MPa / IP-0195 抗冻强度损失 Fm 式(17)）+ GB/T 2542-2012×3
  （IP-0055 抗压 R=P/(L×B)——式体 OCR 塌缩按 7.6.1 符号面转写、remark 明示 /
  IP-0059 吸水率 W24 式(6)+W3 式(7) / IP-0195 抗冻 Pm 式(3)+Gm 式(4)）+
  GB/T 4111-2013×3（IP-0055 附录 A 直测面修约 0.01 MPa（正文芯样推定族 B.5
  不导另注）/ IP-0059 吸水率式(7) 修约 0.1%（块材三件平均 1%）/ IP-0195 单块/
  平均损失率式(12)/(13) 修约 1%），algorithm_type=manual 全族，remark 逐行
  LaTeX 人工判读描述。挂链零新增（P4×三标 TESTING 先前已在；三标全在
  method 40 集）。域面/锚面在 nextjs 仓（同批提交）：semantic-dictionary.json
  增 brick 域（label 砖与砌块，terms 空数组起步——域零卡模板禁倒挂）；
  standard-extract-anchors.json 增 brick 六锚（density/compressive/flexural/
  frost-strength-loss/frost-mass-loss/absorption，clauseKind=clause 照三标
  block_type 实测）；锚/字典期望测试先红后绿（phase lock 正门取证）。
  零硬凑面（11969 劈裂抗拉/轴心抗压/弹模/干燥收缩/碳化等 + 2542 体积密度/
  孔洞率/饱和系数/泛霜/石灰爆裂等 + 4111 含水率/相对含水率/块体密度/空心率/
  B.5 芯样族）=新 IP 码面，转账 45。
  seed:db 重浇 + seed:check clean（dropped 2=账 44 既知）+ DB 探针 P4 十行
  全实；双门绿。守卫计数 37→47（真红 1 条在案；护栏批改顺序教训入账——
  见 HISTORY 教训 7）。兄弟仓同步清单：nextjs（域/锚 JSON+两测试文件+
  守卫计数随批改同批提交）；react/vue 零改动（种子唯一源无镜像回写）。

- feat(seeds): **批S2 土工域立域批——soil 域键+锚三件+GB/T 50123-2019 calc 两行导入（2026-11-18，覆盖推进第 5 批）**——
  seeds 面两处：inspection_calculation_methods.json +2（37 行）：OBJ-SP01-P9 ×
  IP-0226 最大干密度 / IP-0227 最优含水率 × GB/T 50123-2019，algorithm_type=manual，
  rounding=修约到 0.01 g/cm³ / 0.1%，remark 击实曲线族 LaTeX（13.4.2 式
  $\rho_d=\dfrac{\rho}{1+0.01w}$ + 13.4.4 峰值点纵/横坐标判读 + 补点试验条款；
  语料 g/cm² OCR 误置注记归一）。IP-0228 压实系数零硬凑（50123 无算式面，
  该面在验收规范）；JTG 3430-2020 侧击实三行先前已在（同键不同 std 不撞）。
  挂链零新增（P9×50123 TESTING 先前已在；50123 已在 method 40 集）。
  域面/锚面在 nextjs 仓（同批提交）：semantic-dictionary.json 增 soil 域
  （terms 空数组起步——域零卡模板禁倒挂）；standard-extract-anchors.json 增
  soil 三锚（13.4.1/13.4.2/13.4.4，clauseKind=clause 照 50123 语料 block_type
  实测）；锚/字典期望测试先红后绿（phase lock 正门取证）。
  30+ 其余方法扩面=新 IP 码面设计（junction/树镜像），转账 43。
  seed:db 重浇 + seed:check clean + DB 探针 2 行干净；双门绿。
  搭车发现：calc 种子 (P2,IP-0086/0087,228.1) 双胞胎变体行（他批已提交树内件，
  dedupe 各丢 1）→ 挂账 44。兄弟仓同步清单：nextjs（域/锚 JSON+两测试文件+
  守卫计数随批改同批提交）；react/vue 零改动（种子唯一源无镜像回写）。

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
