-- V017 重命名 inspection_calculation_rules → inspection_calculation_methods
--
-- 术语统一：「计算规则」→「计算方法」（v0.x 收尾命名收敛；TS/Java/C# 仓
-- 已同步把 CalculationRule / calculation-rule / calculation-rules / 计算规则
-- 全部换成 CalculationMethod / calculation-method / calculation-methods / 计算方法）。
-- 表结构、列、约束、索引全部不变，只动名字。
--
-- 幂等条件式：本仓 V014（2026-08-24 e6a3975 演进版）已直接 ALTER
-- inspection_calculation_methods —— 部分库（lab_prod VPS）表已叫 methods，
-- 此迁移跳过；仅对仍叫 rules 的库（fresh replay dev）执行 rename。
-- shared 仓的 V014/V015 与本仓分叉待收敛（见 session.json 待办）。

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'inspection_calculation_rules') THEN
    ALTER TABLE inspection_calculation_rules RENAME TO inspection_calculation_methods;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_calc_rule_object') THEN
    ALTER INDEX idx_calc_rule_object RENAME TO idx_calc_method_object;
  END IF;
END $$;

-- COMMENT 沿用（V009 那条 COMMENT 已经写的是「计算方法」，跟新表名一致；不用改）
