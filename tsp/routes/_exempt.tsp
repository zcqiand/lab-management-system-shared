// _exempt.tsp
// 豁免清单（双向打通，变更走 /tree-change）
// 最后更新：2026-09-16 | 维护人：项目所有者
// 关联：docs/adr/0034-contract-tree-iid-strong-binding.md §Decision 3
// 关联：docs/conventions/tsp-routes-exempt.md
//
// 当前：9 条（共享端点——1:1 强绑定下，4 F 共享 + 4 link GET list + 3 shared-with 详情 走豁免）
// 工具链 warning 档跑完后，按 spec §3.3 原则逐条评估（infra 探针 / RFC 协议强制 / 多态响应 / 4 F 共享 / link GET list / shared-with 详情）。

// ── 1. 4 F 共享流程动作端点（按 stage query 参数区分 review/approval/issuance/archived）──
// M03.F05.I03 (审核)/ F06.I03 (批准)/ F07.I03 (发放)/ F08.I03 (归档) 共享此 POST 端点；
// 按 stage query 参数区分阶段，无法拆 4 个 op（同路径同方法多 grant 类比 oauth/token）。
@route("/receipts/flow") op submitFlowAction(): void;
// rationale: 4 F 共享流程动作端点；I 注释挂在各自 F 的 stage 分支

// M03.F05.I01 (审核)/ F06.I01 (批准)/ F07.I01 (发放)/ F08.I01 (归档) 共享此 GET 队列端点；
// 按 stage query 参数区分阶段。
@route("/receipts/flow/queue") op listFlowQueue(): void;
// rationale: 4 F 共享队列端点；I 注释挂在各自 F 的 stage 分支

// ── 2. link GET list 端点（POST link + DELETE unlink 已挂对应 I，GET list 暂未登记）──
// M06.F07.I06 项目↔报告名称 link list（关联 POST/DELETE I06）
@get @route("/report-names/links/object") op listObjectReportNameLinks(): void;
// rationale: POST/DELETE 端点已挂 M06.F07.I06；GET 列表为辅助查询，反向候选 I 集合外

// M06.F07.I07 报告名称↔标准 link list（关联 POST/DELETE I07）
@get @route("/report-names/links/standard") op listStandardReportNameLinks(): void;
// rationale: 同上，POST/DELETE 已挂 I07，GET list 辅助

// M06.F07.I08 报告名称↔参数 link list（关联 POST/DELETE I08）
@get @route("/report-names/links/parameter") op listParameterReportNameLinks(): void;
// rationale: 同上，POST/DELETE 已挂 I08，GET list 辅助

// M06.F08.I06 参数↔界面 link list（关联 POST/DELETE I06）
@get @route("/param-interfaces/links") op listParameterInterfaceLinks(): void;
// rationale: 同上，POST/DELETE 已挂 I06，GET list 辅助

// ── 3. shared-with 共端点（多 I 共 1 端点，1:1 强绑定豁免；其余 I 走反向候选外）──
// M01.F04.I01 (动态菜单身份平台下发) + I04 (lab 侧边栏容器) 共端点 /auth/menus；
// 服务端下发同一份 MenuNode[] 数据，前端 I01 用于导航树、I04 用于侧边栏容器。
// rationale: 同一端点的客户端两套渲染，详见 auth.tsp L42 注释 + function-tree M01.F04.I01/I04 description

// M03.F01.I02 (接样单详情) + F05.I02 (审核详情) + F06.I02 (批准详情) +
// F07.I02 (发放详情) + F08.I02 (归档详情) + F09.I01 (详情聚合) 共端点 /receipts/{id}；
// 报告流程各阶段打开的都是同一个接样单详情，仅客户端按视角渲染不同操作栏。
// rationale: 同一端点的多视角渲染，详见 sample-receipts.tsp L25 注释 + function-tree 6 个 I description

// M03.F02.I01 (任务分配) + I02 (客户端视角 anchor) 共端点 /receipts/{id}/task；
// I02 保留为客户端视角 anchor 不进 fnTest trace（react/vue/nextjs 三仓 data-fn=I01）。
// rationale: 同一端点的客户端两套语义，详见 sample-receipts.tsp L40 注释 + function-tree M03.F02.I01/I02 description