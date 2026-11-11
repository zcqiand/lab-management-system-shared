# REQ-2026-038 通过 Weaviate 标准条款库导入技术要求（钢筋试点）

| 项 | 值 |
|---|---|
| 提出人 | zcqiand |
| 提出日期 | 2026-11-11 |
| 优先级 | P1 |
| 状态 | 开发中 |
| 关联功能 | M06.F06（技术要求 CRUD，无新增子项——本 REQ 是数据面导入管线，非新功能） |
| 关联 ADR | — |

## 1. 需求描述

从外部 Weaviate 向量库（`StandardClauseV1` collection，标准条款 OCR 文本 + 结构化字段
`standard_no`/`std_id`/`clause_id`/`block_type`/`chapter`/`page`）导入技术要求行，
替代/加速人工录入。用户裁定：**先导钢筋**（OBJ-SP01-P2，锚 GB 1499.2-2024），
导入面涉及 型号/规格/牌号/等级 四维度。

## 2. 澄清记录

| # | 问题 | 裁定 |
|---|---|---|
| 1 | 导入形态：在线端点 vs 离线管线？ | **离线管线**（2026-11-11 人裁「先导入钢筋」隐含试点节奏）：脚本拉条款 → 抽取 → 种子草稿行 → 人核 → seed:db。零契约变更、零新端点。 |
| 2 | 抽取引擎？ | 试点纯确定性解析（markdown 表锚 + 启发式归属），抽取不了的进挂起队列；LLM 兜底后置。 |
| 3 | 与现网 verified 行冲突？ | draft 行共存不覆盖；同键冲突在人核报告标注，合并决策归人。 |
| 4 | 等级维度？ | GB 1499.2 源表无等级维度，导入行 grade=null；现网手工行 grade=一级 的口径差异交人核裁定。 |

## 3. 数据面事实（2026-11-11 实测）

- Weaviate 实例 10,118 条款；`std_id=GB_1499.2-2024` 146 条（注意命名：强制标准 `GB_`、
  推荐性 `GB_T_`；`GB_T_1499.2-2018` 旧版另存）。
- 目标源表：**表4** 重量偏差（OCR 干净）/ **表6** 力学性能（OCR 行列错位：400 行丢
  A=16、600 行内联、Agt/比值列塌缩）/ **表7** 弯曲性能（行合并可恢复）。
- 行结构天然支持溯源（`clause`/`source_page`/`source_hash`）与两段流
  （`verification_status`: draft→reviewed→verified，契约语义只有 verified+automatic
  参与自动评定——draft 行天然无害）。
- DDL 约束：`min_value`/`max_value` 是 integer，小数限值（±5.5/1.25/1.30）落
  `expression` 文本列（V014 升 numeric 既有挂账，本 REQ 不动 DDL）。

## 4. 任务拆解

1. T-1 ✅ 抽取管线：`lab-nextjs/_work/import-rebar-tech-req.py` → 71 条草稿
   （45 HIGH / 17 MED / 9 LOW）+ 人核报告 `_work/rebar-import-review.md`。
2. T-2 **人核**（阻塞点，归 zcqiand）：逐行核对 review 报告，LOW 行（Agt 归属）必须裁；
   同键冲突 2 处裁合并。
3. T-3 人核通过 → 草稿行并入 shared `seeds/inspection_technical_requirements.json`
   （draft 状态）→ byte-copy 三镜像 → seed:db → UI 技术要求页复核。
4. T-4（可选，人裁）：扩 GB 1499.1-2024 / GB 13788-2024 / JGJ 107-2016；
   LLM 兜底抽取 LOW 行。

## 5. 验收标准

- 草稿行全部带 clause + source_hash 溯源，verification_status=draft，不影响自动评定。
- 人核报告逐行可对回 OCR 原文；LOW 行零静默转 verified。
- seeds 三镜像 byte-equal，seeds-parity 不变式绿，gate L0-L5 绿。
