using TypeSpec.Http;

// M03.F03 数据录入 — 检测记录 CRUD + 人工改判 verdict
@route("/test-records")
@tag("test-records")
namespace Lab.Management.Shared.TestRecords {
  // M03.F03.I06 检测记录列表
  @get
  op listTestRecords(
    @query page?: int32,
    @query pageSize?: int32,
    @query sampleId?: string,
    @query parameterCode?: string,
  ): Page<TestRecord> | ErrorResponse;

  // M03.F03.I08 创建检测记录
  @post
  op createTestRecord(@body body: CreateTestRecordRequest): TestRecord | ErrorResponse;

  // M03.F03.I07 检测记录详情
  @get
  @route("/{id}")
  op getTestRecord(@path id: string): TestRecord | ErrorResponse;

  // M03.F03.I09 更新检测记录
  @put
  @route("/{id}")
  op updateTestRecord(@path id: string, @body body: UpdateTestRecordRequest): TestRecord | ErrorResponse;

  // M03.F03.I10 删除检测记录
  @delete
  @route("/{id}")
  op deleteTestRecord(@path id: string): void | ErrorResponse;

  // M03.F03.I11 检测记录改判 verdict
  @patch
  @route("/{id}/verdict")
  op setVerdict(@path id: string, @body body: { verdict: string }): TestRecord | ErrorResponse;
}