// _exempt.tsp
// 豁免清单（双向打通，变更走 /tree-change）
// 最后更新：2026-09-17 | 维护人：项目所有者
// 关联：docs/adr/0034-contract-tree-iid-strong-binding.md §Decision 3
// 关联：docs/conventions/tsp-routes-exempt.md
//
// 当前：7 条（共享端点——1:1 强绑定下，4 F 共享 2 条 + 4 link GET list + 1 shared-with 详情）
// 工具链 warning 档跑完后，按 spec §3.3 原则逐条评估（infra 探针 / RFC 协议强制 / 多态响应 / 4 F 共享 / link GET list / shared-with 详情）。

// ── 1. 4 F 共享流程动作端点（按 stage query 参数区分 review/approval/issuance/archived）──
// M03.F05.I03 (审核单条) + F06.I03 (批准单条) + F07.I03 (发放单条) + F08.I03 (归档单条)
// + M03.F05.I05 (批量提交) + F05.I06 (批量退回) 共享此 POST 端点；
// 按 stage query 参数区分阶段，无法拆 4 个 op（同路径同方法多 grant 类比 oauth/token）。
@route("/receipts/flow") op submitFlowAction(): void;
// rationale: 4 F 共享流程动作端点；I 注释挂在各自 F 的 stage 分支

// M03.F05.I01 (审核队列)/ F06.I01 (批准队列)/ F07.I01 (发放队列)/ F08.I01 (归档队列) 共享此 GET 队列端点；
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

// ── 3. shared-with 共端点（多 I 共 1 端点，1:1 强绑定豁免）──
// M03.F01.I07 (接样单 ext 字段补录) + M03.F03.I04 (样品更新) 共端点 /samples/{id}；
// ext 字段补录走前端 modal，提交后调 PUT /api/samples/{id} 持久化到 Sample.ext，与样品编辑同端点。
// rationale: 同一端点的两套业务语义（样品编辑 + ext 字段补录），详见 samples.tsp L27 注释 + function-tree M03.F01.I07/M03.F03.I04 description