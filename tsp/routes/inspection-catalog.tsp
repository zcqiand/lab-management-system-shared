using TypeSpec.Http;

// M04.F06 型号 / F07 规格 / F08 等级 / F09 牌号维护 — 四码表 CRUD（结构同构）
// 列表按检测专项 inspectionObjectCode 过滤；sortOrder 拖拽持久化。
@route("/catalog")
@tag("inspection-catalog")
namespace Lab.Management.Shared.Catalog {
  // ── M04.F09 牌号 ──
  @get
  @route("/brands")
  op listBrands(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionBrand> | ErrorResponse;

  @post
  @route("/brands")
  op createBrand(@body body: CreateCatalogEntryRequest): InspectionBrand | ErrorResponse;

  @put
  @route("/brands/{code}")
  op updateBrand(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionBrand | ErrorResponse;

  @delete
  @route("/brands/{code}")
  op deleteBrand(@path code: string): void | ErrorResponse;

  // ── M04.F06 型号 ──
  @get
  @route("/models")
  op listModels(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionModel> | ErrorResponse;

  @post
  @route("/models")
  op createModel(@body body: CreateCatalogEntryRequest): InspectionModel | ErrorResponse;

  @put
  @route("/models/{code}")
  op updateModel(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionModel | ErrorResponse;

  @delete
  @route("/models/{code}")
  op deleteModel(@path code: string): void | ErrorResponse;

  // ── M04.F07 规格 ──
  @get
  @route("/specs")
  op listSpecs(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionSpec> | ErrorResponse;

  @post
  @route("/specs")
  op createSpec(@body body: CreateCatalogEntryRequest): InspectionSpec | ErrorResponse;

  @put
  @route("/specs/{code}")
  op updateSpec(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionSpec | ErrorResponse;

  @delete
  @route("/specs/{code}")
  op deleteSpec(@path code: string): void | ErrorResponse;

  // ── M04.F08 等级 ──
  @get
  @route("/grades")
  op listGrades(
    @query page?: int32,
    @query pageSize?: int32,
    @query inspectionObjectCode?: string,
    @query keyword?: string,
  ): Page<InspectionGrade> | ErrorResponse;

  @post
  @route("/grades")
  op createGrade(@body body: CreateCatalogEntryRequest): InspectionGrade | ErrorResponse;

  @put
  @route("/grades/{code}")
  op updateGrade(@path code: string, @body body: UpdateCatalogEntryRequest): InspectionGrade | ErrorResponse;

  @delete
  @route("/grades/{code}")
  op deleteGrade(@path code: string): void | ErrorResponse;
}
