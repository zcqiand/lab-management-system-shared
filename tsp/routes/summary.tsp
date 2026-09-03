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

  // M05.F01.I03 核心指标卡
  todayTestCount: int32;
  qualifiedRateByMaterial: {
    concrete: MaterialQualifiedRate;
    rebar: MaterialQualifiedRate;
    sand: MaterialQualifiedRate;
  };
  reportOutputByStatus: {
    generated: int32; // 已生成（reportCode 存在）
    pending: int32;   // 待审核（review+approval）
    issued: int32;    // 已签发（issuance+archived+completed）
  };

  // M05.F01.I04 任务状态漏斗
  funnelByStage: {
    pending_collect: int32; // 待取样（flowStatus=receiving）
    received: int32;        // 已收样（flowStatus=task_assignment）
    testing: int32;         // 试验中（data_entry 且无 reportCode）
    reporting: int32;       // 报告编制（data_entry 且有 reportCode）
    reviewing: int32;       // 待审核（review+approval）
    issued: int32;          // 已签发（issuance+archived+completed）
  };
}

model MaterialQualifiedRate {
  total: int32;
  pass: int32;
  rate: float64; // 0..1
}
