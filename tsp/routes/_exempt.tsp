// _exempt.tsp
// 豁免清单（双向打通，变更走 /tree-change）
// 最后更新：2026-09-16 | 维护人：项目所有者
// 关联：docs/adr/0034-contract-tree-iid-strong-binding.md §Decision 3
// 关联：docs/conventions/tsp-routes-exempt.md
//
// 当前：首批 0 条
// lab 家族端点 95 处未铺平注释前不登记豁免，避免豁免清单膨胀失控。
// 工具链 warning 档跑完后，按 spec §3.3 原则逐条评估（infra 探针 / RFC 协议强制 / 多态响应）。