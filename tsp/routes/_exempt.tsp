// _exempt.tsp
// 2026-09-17 项目所有者决策「相当于没有豁免」——本文件废除，全部豁免逻辑下沉到 inventory 算法：
//   1. infra 路径前缀（/healthz /actuator /oauth/*）自然豁免（ADR-0034 §Decision 3）
//   2. [shared-with: Mxx.Fxx.Ixx] 标注（ADR-0034 §Decision 6 第 3 条）+ function-tree.md 说明列
//   3. link GET list 端点（/report-names/links/* /param-interfaces/links）infra 性质自然豁免
//
// 任何端点多挂 / 0 挂都必须走上述三种通道之一，不接受清单式人工豁免。
// 关联：docs/adr/0034-contract-tree-iid-strong-binding.md §Decision 3 + §Decision 6 第 3 条