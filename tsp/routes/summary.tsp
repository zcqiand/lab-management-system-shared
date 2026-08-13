using TypeSpec.Http;

// M05.F01 报告汇总 — 按报告类别输出试验报告汇总表
@route("/summary")
@tag("summary")
namespace Lab.Management.Shared.Summary {
  // M05.F01 报告汇总（按报告名称 categoryCode 选择汇总口径）
  @get
  op getReportSummary(
    @query categoryCode?: string,
    @query dateFrom?: string,
    @query dateTo?: string,
  ): SummaryData | ErrorResponse;

  // M05 仪表盘统计
  @get
  @route("/stats")
  op getDashboardStats(): DashboardStats | ErrorResponse;
}

model SummaryColumn {
  key: string;
  label: string;
}

model SummaryData {
  summaryName: string;
  columns: SummaryColumn[];
  rows: Record<string>[];
}

model DashboardStats {
  contractCount: int32;
  receiptCount: int32;
  sampleCount: int32;
  reportCountByStatus: {
    draft: int32;
    reviewing: int32;
    issued: int32;
  };
  pendingTaskCount: int32;
}
