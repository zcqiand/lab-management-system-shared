# REQ-2026-042 样品界面维护页 + 基础数据菜单重排（saas 种子洗链）

> 状态：**规划**（2026-11-17 立案，待人批后开工）
> 批队列：REQ-2026-040 头部「加载态批 → 040 → 菜单批」的菜单批，此前从未立案，本文件即其立案。

## 1. 需求描述

用户报「菜单排序和新增菜单都没有调整」（侧边栏基础数据组截图在案）。取证结论：

- 菜单真源链：`saas-identity-platform-shared/seeds/sys_menu.json`（SSOT）→ 灌 saas_dev →
  saas `/api/v1/me/menus?appCode=lab-management` → lab `menu-snapshot.ts` 快照（TTL 30min，
  登录/refresh 时点拉取）→ `GET /api/auth/menus` → 侧边栏。saas_dev 现状=种子 41 行一致。
- 排序与新增都发生在 saas 种子面，lab 侧无任何菜单定义（demo 兜底已删 2026-08-27）。
- 「样品界面」（sri-* 样品扩展属性界面，存 `inspection_report_name_interfaces`）数据面/API 面
  （`/api/report-name-interfaces` 全套）已上线，但**维护页不存在**（仅数据录入弹窗运行时消费）；
  功能树 M06.F09.I01-I07 已登记「前端+后端」。
- 「检测结论」仅为报告模板字段（jcl，数据录入报告预览弹窗内维护），无独立页面——人裁本批不加菜单。

同日收口的数据重复事故（catalog 4 表退出 SSO 镜像，shared 16789cc）已验证检测能力/基础数据
全部平台级无类似问题：全库仅 contracts/sample_receipts/samples/test_records 4 业务表有 tenant_id。

## 2. 澄清记录（2026-11-17 人裁四条）

1. **样品界面** = 新建维护页（形状照 param-interfaces 页：列表+编辑弹窗+关联管理），
   菜单挂「基础数据」组。
2. **检测结论菜单先不加**（字段面维持现状，另批再议）。
3. **基础数据组目标顺序**（人裁原文）：型号 / 规格 / 等级 / 牌号 / 报告名称 / 样品界面 / 参数界面 /
   计算方法 / 技术要求。
4. 计算方法菜单 path 指向旧路由 `inspection-calculation-rules`（25b959a 改名后真身为
   `inspection-calculation-methods`，旧路径仅别名页）——本批一并修正。

**批内扩展人裁两条（2026-11-17 mid-turn 消息）**：

- **「——」占位行统一不增加**（型号维护页截图空名行，红箭头在案）：「要么增加，要么
  不增加，需要统一，趋向不增加」→ 种子全删（照 2026-11-15 既裁「占位归渲染层」），
  models/specs/grades 三表共删 23 行；码表下拉空值占位由渲染层负责。
- **名称去「（seed 补全）」注水后缀**（「名称要按标准中规范灌入，不要有（seed 补全）
  这样的非名称内容」）：5 文件 13 行归正；其中 grades 表 2 行去后缀后与同项目规范行
  真重复（'42.5'/'P6'，规范行 sort 333/111 在案）→ 整行删除。
  执行件=`_work/clean-catalog-seeds.py`（确定性变换，重跑逐字节一致）。

## 3. saas 种子改动面（精确值）

### 3.1 sys_menu.json（clientId=`11111111-1111-1111-1111-111111111111`，基础数据组 parentId=`…910000000006`）

| id（尾段 9100000000xx） | title | path | sortOrder 现→目标 |
|---|---|---|---|
| 017 | 型号维护 | models | 3→1 |
| 018 | 规格维护 | specifications | 4→2 |
| 019 | 等级维护 | grades | 5→3 |
| 020 | 牌号维护 | brands | 6→4 |
| 015 | 报告名称 | report-names | 1→5 |
| **028（新增）** | **样品界面** | **specimen-interfaces** | **6** |
| 016 | 参数界面 | param-interfaces | 2→7 |
| 021 | 计算方法 | inspection-calculation-rules→**inspection-calculation-methods** | 7→8 |
| 022 | 技术要求 | inspection-technical-requirements | 8→9 |

新增行字段照抄同组现行行：parentId=`00000000-0000-0000-0000-910000000006`、type=`menu`、
icon=null、status=1、clientId 同上、createdAt/updatedAt=本批时间。id 序列空位核验：01-27 已用，028 空。

### 3.2 sys_role_menu.json

roleId=`00000000-0000-0000-0000-a00000000001`（tenant 001 admin，现挂全部 27 个 lab 菜单 id）
的 menuIds **追加 `00000000-0000-0000-0000-910000000028`**（27→28）——不追加则所有角色不可见
（saas seed-db.test.ts 授权面断言按种子动态计数，种子间一致即绿）。

### 3.3 重浇 saas_dev

saas seed-db 语义=TRUNCATE 全量重灌（配置型数据全量重灌才是正确幂等，saas 仓自行声明）。
saas_dev 是 dev IdP 库，重浇为常规操作（start-family.sh 同款）。禁碰 prod。

## 4. lab 页面改动面（nextjs）

- 新增路由 `src/app/(console)/specimen-interfaces/page.tsx` → 新组件
  `src/features/inspection-capability/SpecimenInterfaceList.tsx`，形状照
  `ParamInterfaceList.tsx`（列表 + 编辑弹窗 + 关联管理），关联面复用
  `AssociationManager`（报告名称↔界面 links，`/api/report-name-interfaces/links`）。
- **消费既有端点，零端点新增/改/删** → contract-test 同步硬约束（§2）核查零命中；
  页面标题「样品界面」。
- 功能 ID：挂既有 **M06.F09.I01-I07**（接口面已上线，本批是给已上线接口补前端面），**不触树**
  （无 tree-change 提案）；页面触发元素挂 data-fn（reachability）。
- TDD：fnTest 先红后绿（列表渲染/详情/links 管理），红证据入库。

## 5. 任务拆解

- **T1** saas shared 种子：§3.1 重排+修 path+新增 028 行、§3.2 授权追加；saas shared 门绿。
- **T2** saas_dev 重浇 + 探针：sys_menu=42 行、028 在场 sortOrder=6、021 path 新值、
  基础数据组九项顺序=§3.1、admin 授权含 028。
- **T3** lab nextjs：§4 页面（fnTest 先红→实现→绿）；lab nextjs 门绿。
- **T4** live 验证（链路探活→单点→全量）：重登录刷菜单快照，侧边栏基础数据组九项按目标顺序，
  「样品界面」点击进入新页；lab shared + nextjs + saas shared 三门 exit 0；
  CHANGELOG [Unreleased] 记账（saas shared + lab shared 同步清单照单回放）。

## 6. 验收标准

1. saas 种子与 saas_dev：§3 两文件精确落地，探针六项全过（T2 清单）。
2. `/specimen-interfaces` 页面可达且走通：列表出种子内 sri-* 界面、编辑保存、关联报告名称
   增删（fnTest 挂 M06.F09.I01-I07 全绿，红证据在案）。
3. lab 重登录后侧边栏：基础数据组九项顺序 = §2 裁定第 3 条，「样品界面」点击进入新页。
4. 三门（lab shared / lab nextjs / saas shared）exit 0。
5. contract-test 端点面零变化（§2 硬约束核查记录在案）。

## 7. 功能影响

| 类型 | ID | 说明 |
|---|---|---|
| 变更（引用） | M06.F09.I01-I07 | 已上线接口补前端维护页与菜单入口 |
| 不触树 | — | 无新增/废弃 ID，无 tree-change 提案 |
