using TypeSpec.Http;

// M04.F06 型号 / F07 规格 / F08 等级 / F09 牌号维护 — 四码表 CRUD（结构同构）
// 列表按检测专项 inspectionObjectCode 过滤；sortOrder 拖拽持久化。
@route("/catalog")
@tag("inspection-catalog")
namespace Lab.Management.Shared.Catalog {
  // ── M04.F09 牌号 ──
  // M04.F09.I01 牌号列表
  @get
  @route("/brands")
  op listBrands(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionBrand> | ErrorResponse;

  // M04.F09.I02 创建牌号
  @post
  @route("/brands")
  op createBrand(@body body: CreateCatalogEntryRequest): InspectionBrand | ErrorResponse;

  // M04.F09.I03 更新牌号
  @put
  @route("/brands/{code}")
  op updateBrand(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionBrand | ErrorResponse;

  // M04.F09.I04 删除牌号
  @delete
  @route("/brands/{code}")
  op deleteBrand(@path code: string): void | ErrorResponse;

  // ── M04.F06 型号 ──
  // M04.F06.I01 型号列表
  @get
  @route("/models")
  op listModels(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionModel> | ErrorResponse;

  // M04.F06.I02 创建型号
  @post
  @route("/models")
  op createModel(@body body: CreateCatalogEntryRequest): InspectionModel | ErrorResponse;

  // M04.F06.I03 更新型号
  @put
  @route("/models/{code}")
  op updateModel(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionModel | ErrorResponse;

  // M04.F06.I04 删除型号
  @delete
  @route("/models/{code}")
  op deleteModel(@path code: string): void | ErrorResponse;

  // ── M04.F07 规格 ──
  // M04.F07.I01 规格列表
  @get
  @route("/specs")
  op listSpecs(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionSpec> | ErrorResponse;

  // M04.F07.I02 创建规格
  @post
  @route("/specs")
  op createSpec(@body body: CreateCatalogEntryRequest): InspectionSpec | ErrorResponse;

  // M04.F07.I03 更新规格
  @put
  @route("/specs/{code}")
  op updateSpec(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionSpec | ErrorResponse;

  // M04.F07.I04 删除规格
  @delete
  @route("/specs/{code}")
  op deleteSpec(@path code: string): void | ErrorResponse;

  // ── M04.F08 等级 ──
  // M04.F08.I01 等级列表
  @get
  @route("/grades")
  op listGrades(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionGrade> | ErrorResponse;

  // M04.F08.I02 创建等级
  @post
  @route("/grades")
  op createGrade(@body body: CreateCatalogEntryRequest): InspectionGrade | ErrorResponse;

  // M04.F08.I03 更新等级
  @put
  @route("/grades/{code}")
  op updateGrade(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionGrade | ErrorResponse;

  // M04.F08.I04 删除等级
  @delete
  @route("/grades/{code}")
  op deleteGrade(@path code: string): void | ErrorResponse;
}