# REQ-2026-040 加载态统一：全仓数据加载面「先加载中，数据到才渲染」

> 状态：规划（人批后转开发中）
> 来源：用户 2026-11-16 两条指令（六裁）+ 截图（编辑检测标准→关联检测参数页签）：
> 「页面加载数据过程中，都要先显示加载中图片，直到数据加载完成后才显示数据界面」；
> 追加「其他的都要这么过程」= 全仓所有数据加载面。
> 执行顺序：用户批「加载态批 → 040 → 菜单批」——本批第一个开。

## 1. 背景

全仓加载态现状不统一：部分页面首载有整页 PageLoading 门控，但 **refetch（筛选/翻页）
期间刻意保留旧数据**（B6 加载态模式，本 REQ 翻转）；部分弹窗/关联面板/下拉数据源
完全无加载态，加载期间渲染空态「暂无关联」/ 空下拉，数据到了才被顶替——用户看到
的就是「没在加载、直接是空/旧界面」。

## 2. 澄清记录

| # | 问题 | 裁定 |
|---|---|---|
| 1 | refetch（筛选/翻页）期间保旧数据还是显示加载中？ | **显示加载中**（用户「都要」绝对化，推翻既有 B6「refetch 不清空旧列表」行为；用户为规格权威，最新指令优先）。 |
| 2 | 「数据界面」边界？ | **页面骨架/弹窗外壳/工具栏/标题等 chrome 可先渲染；数据区（列表/表格/树节点/下拉选项/关联面板/预览正文）必须门控**——fetch 进行中显示加载指示，数据到达才渲染。 |
| 3 | 加载失败的显示？ | error 时显示既有错误条（role=alert），**不得停在永久加载**；错误不算数据，「加载中」态随之结束。 |
| 4 | 保存/提交按钮的「保存中…」？ | 不在本批范围（saving ≠ 数据加载态）。 |
| 5 | 加载指示用什么？ | **零新增原语**：页面级复用 `PageLoading`；区域级复用既有行内「加载中...」行/文本。不引入 Skeleton/Spinner 新组件。 |

## 3. 规约（唯一行为标准，逐面对照执行）

1. **数据区门控**：凡 fetch 触发的数据区，`loading === true` 期间渲染加载指示、
   不渲染旧数据/空态替身；数据到达（或 error）后才渲染数据/错误。
2. **门控条件**：首载与 refetch 一视同仁——门控写 `loading`，**禁** `loading && list.length === 0`
   （后者即 B6 保旧数据，本批全数翻转）。
3. **zustand store 面**：消费列表页在首帧就可能渲染 store 数据的，store `loading`
   初始值改 `true`（fetch 开始前不闪空态）。
4. **懒加载子区**（树展开节点/级联下拉）：子区自身显示「加载中...」，不影响已就绪区。
5. **错误终态**：每个被翻转面保留/补齐 error 分支（既有 error 条样式）。

## 4. 加载面清单（盘点真源，2026-11-16 Explore 全扫）

**A 组：B6 翻转（门控条件去 `&& length===0`，refetch 期间显示加载中）**

| 面 | 文件 | 现门控行 |
|---|---|---|
| 检测能力维护页 | InspectionCapabilityPage.tsx | :326 |
| 两级树（项目/标准） | TwoLevelObjectStandardTree.tsx | :348（objectsReady） |
| 参数界面列表 | ParamInterfaceList.tsx | :198 |
| 报告名称列表 | ReportNameList.tsx | :209 |
| 码表维护页 | CategoryDictList.tsx | :298 |
| 合同列表 | app/(console)/contracts/page.tsx | :65（isFetching 提示 :146 一并翻转） |
| 流程线通用页（接样/审核/批准/签发/归档） | FlowStagePage.tsx | :281 |
| 统计汇总 | SummaryPage.tsx | :128（三源 ready） |

**B 组：无加载态→补门控（数据区加载期间渲染空态/空下拉，需显示加载中）**

| 面 | 文件 | 现状 |
|---|---|---|
| 关联管理面板 | AssociationManager.tsx | 加载中渲染「暂无关联」:454 |
| 技术要求列表 | TechnicalRequirementList.tsx | 列表自身无门控（依赖树门控） |
| 计算方法页表单下拉源 | CalculationMethodList.tsx | 下拉源静默空 |
| 接样单详情面板 | ReceiptDetail.tsx | loading 初始 false（:89），仅行内文本 :188 |
| 接样表单弹窗 | ReceiptFormModal.tsx | 弹窗体/下拉在来源加载期间空渲染 |
| 样品管理列表 | SampleList.tsx | 仅空表壳 + 条件行内文本 :159 |
| 样品管理弹窗 | SampleManagerModal.tsx | loading 初始 false（:103），字典下拉空渲染 |
| 报告预览弹窗 | ReportPreviewModal.tsx | A4 外壳先渲染（数据区 :303 有提示，收口到数据区门控） |
| 报告名称界面源 hook | models/reportNameInterface.ts | 无 loading 透出（消费方静默空） |

**C 组：已合规（仅校验不改动）**：DataEntryPage（自定义门控+加载中文案）、
ReceiptDetailPage（loading 初始 true）、DynamicFormRenderer、侧边菜单
（菜单加载中…）、路由级 loading.tsx、InspectionCapabilityFormModal（自身无 fetch）、
SampleFormModal、SampleExtFieldsModal、TaskAssignmentPage、FlowPanel、登录页。

## 5. 验收标准

- §4 A/B 组每个面：fetch 进行中数据区显示加载指示；**refetch 期间旧数据不可见**；
  error 终态显示错误条不停加载。
- 既有断言旧加载行为的测试随批更新（tests/features/loading、summary、reports、
  dicts、inspection-capability 各 dom 套件）。
- 零新增加载原语组件；「保存中…」类 saving 面不受影响。
- 全组 vitest 绿 + 双门 gate（shared+nextjs）exit 0。
- 功能树影响面：本批为既有页面行为细化，无新增功能 ID；不触树。

## 6. 任务拆解

- T1 检测能力族：InspectionCapabilityPage + AssociationManager + TechnicalRequirementList
  + CalculationMethodList 下拉源（同目录同批）
- T2 树与列表族：TwoLevelObjectStandardTree 懒加载子区 + ParamInterfaceList + ReportNameList
- T3 字典与合同族：CategoryDictList + contracts/page
- T4 流程线族：FlowStagePage + SummaryPage
- T5 接样/样品族：ReceiptDetail + ReceiptFormModal + SampleList + SampleManagerModal
  + ReceiptList 合同下拉源 + reportNameInterface hook loading 透出
- T6 录入/预览族：ReportPreviewModal 数据区门控 + C 组合规校验（补断言不加行为）
- T7 收官：store loading 初始值核对面 + 全组测试 + 双门 gate + CHANGELOG + REQ 状态
  更新 + suite 收口 commit
