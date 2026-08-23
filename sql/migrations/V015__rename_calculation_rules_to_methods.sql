-- V015 重命名 inspection_calculation_rules → inspection_calculation_methods
--
-- 术语统一：「计算规则」→「计算方法」（v0.x 收尾命名收敛；TS/Java/C# 仓
-- 已同步把 CalculationRule / calculation-rule / calculation-rules / 计算规则
-- 全部换成 CalculationMethod / calculation-method / calculation-methods / 计算方法）。
-- 表结构、列、约束、索引全部不变，只动名字。

ALTER TABLE inspection_calculation_rules RENAME TO inspection_calculation_methods;

-- 索引名跟着改（PG 不自动重命名 index，要手动）—— 重建同名 index 引用新表
ALTER INDEX idx_calc_rule_object RENAME TO idx_calc_method_object;

-- COMMENT 沿用（V009 那条 COMMENT 已经写的是「计算方法」，跟新表名一致；不用改）
