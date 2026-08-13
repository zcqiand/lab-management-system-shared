-- V007__indexes.sql
-- 次要索引集中（热路径索引已在各 V 内联）。
-- 码表 sort_order 索引：支撑 M04 拖拽排序持久化查询。

CREATE INDEX idx_inspection_brands_sort ON inspection_brands (sort_order);
CREATE INDEX idx_inspection_models_sort ON inspection_models (sort_order);
CREATE INDEX idx_inspection_specs_sort  ON inspection_specs  (sort_order);
CREATE INDEX idx_inspection_grades_sort ON inspection_grades (sort_order);

-- contracts 状态过滤（M02.F01 列表三态）
CREATE INDEX idx_contracts_status ON contracts (status);

-- test_records 按参数维度查（M03.F03 录入列表）
CREATE INDEX idx_test_records_parameter ON test_records (parameter_code);
