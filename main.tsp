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

using TypeSpec.Http;

// ============================================================
// Lab Management System — 实验室管理系统 TypeSpec SSOT
// 唯一真源。产 OpenAPI → orval (TS api-client/msw)
//                       → openapi-generator-java (Spring)
//                       → NSwag (ASP.NET Core)
// 简化范围：保留 backup 17 个「已上线」功能，丢弃已废弃 + 规划（M06/M07 全砍）。
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
