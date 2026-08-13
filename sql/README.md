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
- **枚举**：PG 原生 `CREATE TYPE <name> AS ENUM (...)`；值用单引号小写 snake_case
- **JSONB 字段**：命名 `<name>`（不加 `_json` 后缀）；`flow_history` 为数组
- **删除策略**：M03 业务表 `ON DELETE CASCADE`（samples/receipts 级联）；contracts 对 receipts `ON DELETE RESTRICT`；tech_req 对四码表 `ON DELETE SET NULL`

## Migrations（V001..V007 落地 10 表 + 8 enum）

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

8 个 enum：`contract_status` / `flow_status` / `receipt_result` / `requirement_value_type` /
`requirement_comparison` / `requirement_verification_status` / `requirement_judgment_mode` / `audit_action`。

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
