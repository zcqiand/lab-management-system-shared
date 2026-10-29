using TypeSpec.Http;

// M02.F01 合同管理 — CRUD
@route("/contracts")
@tag("contracts")
namespace Lab.Management.Shared.Contracts {
  // M02.F01.I01 列表
  @get
  op listContracts(
    @doc("当前实现仅回显，不切片：参照实现返回全量，无分页语义。") @query page?: int32,
    @doc("当前实现仅回显，不切片。") @query pageSize?: int32,
    @query keyword?: string,
    @query status?: ContractStatus,
  ): Page<Contract> | ErrorResponse;

  // M02.F01.I02 创建
  @post
  op createContract(@body body: CreateContractRequest): Contract | ErrorResponse;

  // M02.F01.I03 详情
  @get
  @route("/{id}")
  op getContract(@path id: string): Contract | ErrorResponse;

  // M02.F01.I04 更新
  @put
  @route("/{id}")
  op updateContract(@path id: string, @body body: UpdateContractRequest): Contract | ErrorResponse;

  // M02.F01.I05 删除
  @delete
  @route("/{id}")
  op deleteContract(@path id: string): void | ErrorResponse;
}
