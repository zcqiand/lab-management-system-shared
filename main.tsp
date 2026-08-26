import "@typespec/http";
import "@typespec/openapi3";
import "@typespec/rest";

// --- Models ---
import "./tsp/models/common.tsp";
import "./tsp/models/contract.tsp";
import "./tsp/models/sample-receipt.tsp";
import "./tsp/models/sample.tsp";
import "./tsp/models/test-record.tsp";
import "./tsp/models/inspection-catalog.tsp";
import "./tsp/models/technical-requirement.tsp";
import "./tsp/models/audit-event.tsp";
import "./tsp/models/inspection-dictionary.tsp";
import "./tsp/models/report-name.tsp";
import "./tsp/models/calculation-method.tsp";
import "./tsp/models/param-interface.tsp";

// --- Frontend Bind Contracts (Sprint 1) ---
import "./tsp/contracts/frontend-bind.tsp";

// --- Routes ---
import "./tsp/routes/auth.tsp";
import "./tsp/routes/contracts.tsp";
import "./tsp/routes/sample-receipts.tsp";
import "./tsp/routes/samples.tsp";
import "./tsp/routes/test-records.tsp";
import "./tsp/routes/report-flow.tsp";
import "./tsp/routes/inspection-catalog.tsp";
import "./tsp/routes/technical-requirements.tsp";
import "./tsp/routes/summary.tsp";
import "./tsp/routes/inspection-dictionary.tsp";
import "./tsp/routes/report-names.tsp";
import "./tsp/routes/calculation-methods.tsp";
import "./tsp/routes/param-interfaces.tsp";

using TypeSpec.Http;

// ============================================================
// Lab Management System — 建筑工程实验室管理系统 TypeSpec SSOT
// 唯一真源。产 OpenAPI → orval (TS api-client/msw)
//                       → openapi-generator-java (Spring)
//                       → NSwag (ASP.NET Core)
// 范围：M01 认证 / M02 资源 / M03 试验过程 / M04 基础数据(码表)
//       / M05 统计 / M06 检测能力(专项/项目/参数/标准/计算方法/技术要求/报告名称/参数界面)。
// ============================================================

@service
@server("https://api.example.com", "Production")
@route("/api")
namespace Lab.Management.Shared;


// ============================================================
// Common error response
// ============================================================
@error
model ErrorResponse {
  @example("BAD_REQUEST") code: string;
  message: string;
  details?: Record<unknown>;
}

// ============================================================
// Pagination wrapper
// ============================================================
model Page<T> {
  items: T[];
  @example(1) page: int32;
  @example(20) pageSize: int32;
  @example(0) total: int64;
}

// ============================================================
// Generic ID wrapper
// ============================================================
model CreatedResponse {
  id: string;
}
