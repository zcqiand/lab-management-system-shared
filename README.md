# 实验室管理系统 · 契约仓

建筑工程实验室管理系统全家族的契约源头 —— TypeSpec 真源，产出 OpenAPI 3.1 与 SQL DDL（家族唯一真源）。

本仓为《（书稿信息待补）》案例（待补）的可运行配套工程，是书稿代码块的 **source of truth**。

## 快速开始

```bash
npm install       # 安装依赖（@typespec/* dev）
npm run build     # tsp compile → 只跑 emit:openapi
npm test          # 全量测试（无 Key / 无 Docker / 无网可跑）
```

## 功能特性

- `tsp/*.tsp` 契约真源：API 层契约（OpenAPI 3.1）由 `tsp compile` 生成，禁止手写 yaml
- `sql/migrations/*.sql`：数据库 DDL 真源（Flyway 风格 `V<NNN>__<desc>.sql`，ADR-0007）
- 消费方：react / vue / nextjs / springboot / aspnetcore / msw 六仓各自 generate 语言专属产物

## 技术栈

| 技术 | 版本 |
| :--- | :--- |
| TypeSpec compiler | ^1.0.0 |
| @typespec/http | ^1.15.0 |
| @typespec/openapi3 | ^1.0.0 |
| TypeScript | ^5.7.0 |
| Vitest | ^2.1.0 |

> 依赖版本与 `version-lock.json` 的 `version_lock` 一致，不引入 lock 外的库。

## 配套书籍及章节映射

| 章 | 主题 | 对应源文件 |
| :--- | :--- | :--- |
| （待补） | | |

## 快速链接

- [CLAUDE.md](CLAUDE.md) — 开发约定与编码规范
- [系统架构.md](docs/ARCHITECTURE.md) — 结构 / 边界 / 数据流 / 决策
- [功能规格.md](docs/functions/function-tree.md) — 功能名称、描述与验收标准
- [未来开发计划](PLAN.md) — 待办与迭代方向
- [更新日志](CHANGELOG.md) — 版本变更记录
