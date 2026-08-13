# lab-management-system-shared

> 纯契约仓。`*.tsp` 是唯一真源，**只产出 OpenAPI yaml**。语言专属客户端（TS / Java / C#）由各消费方仓自己 generate。

## 1. 这是什么

lab-management-system 全家桶的契约源头。其它 6 个仓（react/vue/nextjs/springboot/aspnetcore/msw）通过 `generated/openapi/openapi.yaml` 消费契约。

简化范围：保留 backup 17 个「已上线」功能（5 模块），丢弃已废弃（M01.F01-F03 / M03.F04 / M04.F01-F04/F10/F12）与规划（M06 检测能力 / M07 shared 后端模拟整模块）。

## 2. 禁止事项

- 禁止业务代码（handlers/services/controllers）
- 禁止生成语言专属产物（TS/Java/C# 客户端代码一律下放给消费方自己 generate）
- 禁止 npm runtime 依赖（仅 `@typespec/*` dev）
- 禁止手写 OpenAPI yaml（必须由 `tsp compile` 生成）
- 禁止 npm package 的 `exports` 暴露语言路径；只暴露 `./openapi` yaml 路径
- **允许** `sql/migrations/*.sql` 作为数据库 DDL 真源（Flyway 风格 `V<NNN>__<desc>.sql`；见 ADR-0007）。**禁止**在该目录写应用语言代码；**禁止**手写迁移工具脚本

## 3. 指向别处

- `/init-project` — 同仓再生成
- `gate-runner` skill — 跑门禁
- 类型契约：`docs/functions/function-tree.md` 与 `tsp/routes/*.tsp` 一一对应
- 多仓家族拓扑：suite `docs/conventions/multi-repo-family.md`

## 4. 工作循环

1. 改 `tsp/main.tsp` 或子文件
2. `npm run build`（**只跑 emit:openapi**）
3. `python scripts/gate.py -p lab-management-system-shared`
4. 0 = 绿；1 = 修代码；2 = 停下问人
