using TypeSpec.Http;

// M03.F03 数据录入 — 检测记录 CRUD + 人工改判 verdict
@route("/test-records")
@tag("test-records")
namespace Lab.Management.Shared.TestRecords {
  @get
  op listTestRecords(
    @query page?: int32,
    @query pageSize?: int32,
    @query sampleId?: string,
    @query parameterCode?: string,
  ): Page<TestRecord> | ErrorResponse;

  @post
  op createTestRecord(@body body: CreateTestRecordRequest): TestRecord | ErrorResponse;

  @get
  @route("/{id}")
  op getTestRecord(@path id: string): TestRecord | ErrorResponse;

  @put
  @route("/{id}")
  op updateTestRecord(@path id: string, @body body: UpdateTestRecordRequest): TestRecord | ErrorResponse;

  @delete
  @route("/{id}")
  op deleteTestRecord(@path id: string): void | ErrorResponse;

  // M03.F03.I06 人工改判 verdict
  @patch
  @route("/{id}/verdict")
  op setVerdict(@path id: string, @body body: { verdict: string }): TestRecord | ErrorResponse;
}
