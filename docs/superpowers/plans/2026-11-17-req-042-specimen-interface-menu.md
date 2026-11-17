# REQ-2026-042 样品界面维护页 + 基础数据菜单重排 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (native inline——四任务仅 T3 是开发件且强顺序依赖前面的种子/库态，本批选 native)。

**Goal:** 基础数据菜单九项按人裁顺序重排 + 新增「样品界面」菜单与维护页 + 计算方法 path 对齐。

**Architecture:** 菜单真源=saas shared seeds → 重浇 saas_dev → lab 登录快照下发；维护页照 ParamInterfaceList 形状消费既有 `/api/report-name-interfaces` 端点（零端点变化）。

**Tech Stack:** JSON 种子 + node seed-db 脚本 + Next.js console 页 + vitest fnTest。

**Spec:** `docs/requirements/REQ-2026-042-specimen-interface-menu.md`（全部精确值在 §3/§4，本计划不转录）。

## Global Constraints

- 新菜单 id=`00000000-0000-0000-0000-910000000028`（序列空位已核），授权必须同步 `sys_role_menu` admin 行，否则全员不可见
- saas 灌库语义=TRUNCATE 全量重灌；只碰 saas_dev（`127.0.0.1:54321`，postgres/postgres），禁 prod
- 零端点新增/改/删——contract-test 不同步（硬约束 §2 核查记录进 T4 报告）
- 页面功能挂既有 M06.F09.I01-I07，不触树；触发元素挂 data-fn
- npm 命令一律 `npx --no -- <tool>`；过程件进 `_work/`；长 CJK 写盘后读盘回验
- lab nextjs red 区纪律：fnTest 先红留证据（red.json/red 输出）再写实现

## Review Focus

- sortOrder 重排后基础数据组不得出现重号/跳号；目标顺序以 REQ §2 裁定第 3 条为唯一真源
- 021 path 改后旧路由别名页仍在（`inspection-calculation-rules` 别名不删，属 25b959a 遗留兼容）
- 新页面对 sri-* 种子行的渲染不得依赖 sortOrder 之外的隐式顺序（列表按 API 返回序）
- 菜单快照 TTL 30min：live 验证必须重登录（或 refresh）触发拉取，不能只等 TTL

---

### Task 1: saas 种子洗链（REQ §3）

**Files:**
- Modify: `output/saas-identity-platform-shared/seeds/sys_menu.json`
- Modify: `output/saas-identity-platform-shared/seeds/sys_role_menu.json`

**Interfaces:**
- Produces: saas_dev 重浇后的菜单面（Task 2 消费）；lab 侧边栏新顺序（Task 4 消费）

- [ ] 按 REQ §3.1 表改 8 行 sortOrder + 021 path + 追加 028 行（字段照抄同组现行行，createdAt/updatedAt=2026-11-17）
- [ ] 按 REQ §3.2 admin 行 menuIds 追加 028（27→28 个）
- [ ] 验证：`python -c json.load` 双文件解析通过；028 恰好出现一次（sys_menu）+ 一次（sys_role_menu）；基础数据组 sortOrder 恰为 1-9 无重号
- [ ] saas shared 门：`python scripts/gate.py -p saas-identity-platform-shared` exit 0
- [ ] Commit（saas shared 仓）

### Task 2: saas_dev 重浇 + 探针（REQ §3.3）

**Files:** 无文件改动（库操作 + `_work/` 过程件）

- [ ] `DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54321/saas_dev node scripts/seed-db.mjs`（saas shared 仓根，bash inline env）
- [ ] 探针六项（psycopg，参数化断言）：①sys_menu=42 行 ②028 在场且 sortOrder=6/path=specimen-interfaces ③基础数据组九项顺序=REQ §2 裁定 ④021 path=inspection-calculation-methods ⑤admin 授权含 028（sys_role_menu）⑥/type 字典值形状与同组一致
- [ ] 探针脚本落 `output/saas-identity-platform-shared/_work/probe-req-042.py`，输出存档

### Task 3: lab 样品界面维护页（REQ §4）

**Files:**
- Create: `output/lab-management-system-nextjs/src/app/(console)/specimen-interfaces/page.tsx`
- Create: `output/lab-management-system-nextjs/src/features/inspection-capability/SpecimenInterfaceList.tsx`
- Test: `output/lab-management-system-nextjs/src/features/inspection-capability/__tests__/SpecimenInterfaceList.test.tsx`（落点照 ParamInterfaceList 既有测试位置惯例，先查再定）

**Interfaces:**
- Consumes: `src/api/endpoints/report-name-interfaces/*` 既有 client（list/detail/create/update/delete/links）
- Produces: 路由 `/specimen-interfaces`；侧边栏菜单点入面

- [ ] 先查 ParamInterfaceList 测试落点与形状（列表/弹窗/关联三块），fnTest 照惯例挂 M06.F09.I01-I07
- [ ] 写失败测试（列表渲染 sri-* 行 + 编辑弹窗开合 + 关联管理），跑红，红证据存 `_work/`
- [ ] 实现组件与路由（形状照 ParamInterfaceList，标题「样品界面」），跑绿
- [ ] `python scripts/gate.py -p lab-management-system-nextjs` exit 0
- [ ] Commit（lab nextjs 仓）

### Task 4: live 验证 + 三门 + CHANGELOG 收口（REQ §5/§6）

**Files:**
- Modify: 两 shared 仓 `CHANGELOG.md`（[Unreleased]）

- [ ] lab dev 起服，重登录拉新菜单快照：侧边栏基础数据组九项按目标顺序，「样品界面」点击进入 `/specimen-interfaces`，列表出种子数据
- [ ] 三门 exit 0：lab shared / lab nextjs / saas shared
- [ ] CHANGELOG 记账（saas shared + lab shared），sibling 同步清单照单回放
- [ ] session.json 交接更新
