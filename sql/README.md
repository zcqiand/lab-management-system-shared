# shared/sql/ — DB 持久层 SSOT

> PostgreSQL DDL 真源。后端（springboot Flyway / aspnetcore EF Migrations / nextjs Drizzle）从此处消费。
> 见 ADR-0007（shared 仓双 SSOT：API 契约 + DB schema）。

## 命名约定

- **文件名**：`V<NNN>__<description>.sql`（Flyway 风格；单调递增；不允许修改已落地文件）
- **表名**：复数 snake_case（`contracts` / `sample_receipts` / `samples`）
- **列名**：snake_case（`contract_id` / `created_at` / `flow_status`）
- **FK 列**：`<entity_singular>_id`（`contract_id` 指向 `contracts.id`）
- **主键**：`text`（应用层 uuid 字符串，与 backup 约定一致），非 PG uuid 生成
- **时间戳**：`text`（ISO 字符串）`NOT NULL DEFAULT ''`；`sample_receipts.issued_at` 例外为 `timestamptz`
- **枚举**：**V014 起统一改为 TEXT**（V001-V008 的 PG enum 列通过 V014 一次性全部 ALTER
  COLUMN ... TYPE text + DROP TYPE CASCADE）。原因：Hibernate 6 @Enumerated(STRING) 默认传
  enum 常量名（`SIMPLE_AVG`），与 PG enum 小写标签（`simple_avg`）不一致；@JdbcTypeCode(NAMED_ENUM)
  在 Hibernate 6 缺工具支持。改 TEXT 后各仓 JPA 端用 AttributeConverter 显式写 DTO @JsonValue 同款
  字符串（小写）。TypeSpec 契约层不变（DTO enum 仍走 small snake_case），SSOT 强约束由 OpenAPI
  `enum: [...]` 兜底。原始 enum 类型全部 DROP，引用走 TEXT 单路径。12 个 enum 转 TEXT 见 V014。
- **JSONB 字段**：命名 `<name>`（不加 `_json` 后缀）；`flow_history` 为数组
- **删除策略**：M03 业务表 `ON DELETE CASCADE`（samples/receipts 级联）；contracts 对 receipts `ON DELETE RESTRICT`；tech_req 对四码表 `ON DELETE SET NULL`

## Migrations（V001..V014 落地 13 表 + 0 PG enum，V014 统一 enum→TEXT）

| 表 | V 文件 | TypeSpec model | 业务域 |
|---|---|---|---|
| `contracts` | V001 | Contract / ContractStatus | M02.F01 |
| `sample_receipts` | V002 | SampleReceipt / FlowStatus / ReceiptResult | M03.F01-F09 |
| `samples` | V002 | Sample | M03.F02/F03 |
| `test_records` | V003 | TestRecord | M03.F03 |
| `inspection_brands` | V004 | InspectionBrand | M04.F09 |
| `inspection_models` | V004 | InspectionModel | M04.F06 |
| `inspection_specs` | V004 | InspectionSpec | M04.F07 |
| `inspection_grades` | V004 | InspectionGrade | M04.F08 |
| `inspection_technical_requirements` | V005 | TechnicalRequirement + 4 requirement enum | M04.F05 |
| `audit_events` | V006 | AuditEvent / AuditAction | M01.F04/F05 |
| `inspection_specialties` / `inspection_objects` / `inspection_specialty_objects` / `inspection_parameters` / `inspection_standards` / `inspection_object_parameters` / `inspection_object_standards` / `inspection_standard_parameters` | V008 | InspectionSpecialty / Object / Parameter / Standard + 4 junction | M06.F01-F04 |
| `inspection_report_names` / `inspection_object_report_names` / `inspection_report_name_standards` / `inspection_report_name_parameters` / `inspection_calculation_methods` | V009 | InspectionReportName + 3 junction + CalculationMethod | M06.F05/F07 |
| `inspection_param_interfaces` / `inspection_param_interface_links` | V010→V013 rename | ParamInterface + link | M06.F08 |

V014 转换的 12 个 enum（V001/V002/V005/V008/V009 引入，V014 落地时全部 PG enum→TEXT）：

| Enum | 来源 V | 引用表 |
|---|---|---|
| `contract_status` | V001 | `contracts.status` |
| `flow_status` | V002 | `sample_receipts.flow_status` |
| `receipt_result` | V002 | `sample_receipts.result` |
| `requirement_value_type` / `requirement_comparison` / `requirement_verification_status` / `requirement_judgment_mode` | V005 | `inspection_technical_requirements.*` |
| `calculation_algorithm_type` | V009 | `inspection_calculation_methods.algorithm_type` |
| `inspection_parameter_source_type` / `inspection_standard_status` / `qualification_level` / `inspection_standard_role` | V008 | 字典 4 表 + 2 张 role junction |

未转换：`audit_action`（V006 引入）。原因：当前 springboot 仓 AuditEvent entity 尚未对接
（springboot B1 阶段未实现 audit 端点），如未来 springboot 加 audit 端点需再补一个 V015 单独转换。

## 逻辑 FK（不强制）

M06 检测能力（专项/项目/参数/标准/对象/报告名称）已按简化决策全部废弃。引用这些表的
列保留为 `text`，仅作逻辑字符串引用，不加 `FOREIGN KEY`。M04 四码表与 M04.F05 技术要求
之间用真实 FK（`ON DELETE SET NULL`）。

## 各后端消费方式

| 后端 | 复制路径 | 执行 |
|---|---|---|
| springboot | `scripts/gen-shared.sh` → `src/main/resources/db/migration/` | Flyway 启动时自动跑 |
| aspnetcore | `scripts/gen-shared.sh` → `Migrations/` 旁 | `dotnet ef migrations` 镜像 |
| nextjs | `scripts/gen-shared.sh` → `migrations/` | `node-pg-migrate up` |

## 验证

```bash
# 直推（dev 期快速重建）
node scripts/sync-db.mjs                    # 全量重建（默认 lab_dev @ 100.79.128.25）
node scripts/sync-db.mjs --incremental      # 增量

# 自动重放（L4 门禁）
npx vitest run tests/sql.replay.test.ts     # 需 PG；PG_REPLAY_SKIP=1 可跳过
```

## 注意事项

- **禁止修改已落地 V 文件**（Flyway 兼容语义）。改字段只能加新 `V00N+1__*.sql`。
- **每个 V 文件必须独立可执行**。
- **本目录只承载 PostgreSQL DDL**，不写 TS / Java / C# 应用代码（CLAUDE.md §2）。
