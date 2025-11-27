package controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/auth/entities"
	"myfashion/internal/modules/catalog/api"
	catalogEntities "myfashion/internal/modules/catalog/entities"
	"myfashion/internal/modules/catalog/repositories"
	"myfashion/internal/modules/catalog/services"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

type CatalogController struct {
	categorySvc *services.CategoryService
	styleSvc    *services.StyleService
	productSvc  *services.ProductService
	brandSvc    *services.BrandService

	// repos for new product flow
	db                 *gorm.DB
	prodRepo           services.ProductRepository
	prodColorRepo      services.ProductColorRepository
	prodColorImageRepo services.ProductColorImageRepository
	prodVariantRepo    services.ProductVariantRepository
	prodStatsRepo      services.ProductStatsRepository
}

func NewCatalogController(db *gorm.DB) *CatalogController {
	catRepo := repositories.NewCategoryGormRepo(db)
	styleRepo := repositories.NewStyleGormRepo(db)
	prodRepo := repositories.NewProductGormRepo(db)
	brandRepo := repositories.NewBrandRepository(db)

	// new repos for product flow
	prodColorRepo := repositories.NewProductColorGormRepo(db)
	prodColorImageRepo := repositories.NewProductColorImageGormRepo(db)
	prodVariantRepo := repositories.NewProductVariantGormRepo(db)
	prodStatsRepo := repositories.NewProductStatsGormRepo(db)

	return &CatalogController{
		categorySvc:        services.NewCategoryService(catRepo),
		styleSvc:           services.NewStyleService(styleRepo),
		productSvc:         services.NewProductService(prodRepo, catRepo, styleRepo),
		brandSvc:           services.NewBrandService(brandRepo),
		db:                 db,
		prodRepo:           prodRepo,
		prodColorRepo:      prodColorRepo,
		prodColorImageRepo: prodColorImageRepo,
		prodVariantRepo:    prodVariantRepo,
		prodStatsRepo:      prodStatsRepo,
	}
}

// --- Helpers ---

func (c *CatalogController) isShop(r *http.Request) bool {
	claims := authn.GetClaims(r.Context())
	return claims != nil && claims.Role == string(entities.RoleShop)
}

func (c *CatalogController) parseID(w http.ResponseWriter, r *http.Request, key string) (uint, bool) {
	idStr := chi.URLParam(r, key)
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id")
		return 0, false
	}
	return uint(id), true
}

// --- Brand Handlers ---

// @Summary Create brand
// @Description Tạo mới một thương hiệu (chỉ dành cho shop/admin)
// @Security Bearer
// @Tags Brands
// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Brand name"
// @Param logo formData file false "Logo image file (jpg, jpeg, png, gif)"
// @Success 201 {object} resp.Envelope{data=api.BrandResponse}
// @Failure 400 {object} resp.Envelope
// @Router /admin/brands [post]
func (c *CatalogController) CreateBrand(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}

	if err := r.ParseMultipartForm(10 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse form data")
		return
	}

	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		resp.Error(w, http.StatusBadRequest, "name is required")
		return
	}

	var logoURL string
	file, header, err := r.FormFile("logo")
	if err == nil {
		defer file.Close()
		if err := validation.ValidateImageFile(header); err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		saved, err := saveBrandLogoFile(file, header)
		if err != nil {
			resp.Error(w, http.StatusInternalServerError, "failed to save logo file")
			return
		}
		logoURL = saved
	} else if err != http.ErrMissingFile {
		resp.Error(w, http.StatusBadRequest, "invalid logo file")
		return
	}

	brand, err := c.brandSvc.Create(r.Context(), name, logoURL)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	resp.Created(w, api.ToBrandResponse(brand))
}

func saveBrandLogoFile(src multipart.File, header *multipart.FileHeader) (string, error) {
	ext := filepath.Ext(header.Filename)
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	uploadDir := "uploads/brands"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return "", err
	}
	dstPath := filepath.Join(uploadDir, filename)
	dst, err := os.Create(dstPath)
	if err != nil {
		return "", err
	}
	defer dst.Close()
	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}
	return "/" + filepath.ToSlash(filepath.Join(uploadDir, filename)), nil
}

// @Summary Update brand
// @Description Cập nhật thông tin một thương hiệu
// @Security Bearer
// @Tags Brands
// @Accept json
// @Produce json
// @Param id path int true "Brand ID"
// @Param body body api.BrandRequest true "Brand payload"
// @Success 200 {object} resp.Envelope{data=api.BrandResponse}
// @Failure 400 {object} resp.Envelope
// @Router /admin/brands/{id} [put]
func (c *CatalogController) UpdateBrand(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}

	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	var req api.BrandRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	brand, err := c.brandSvc.Update(r.Context(), id, req.Name, req.LogoURL)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	resp.OK(w, api.ToBrandResponse(brand))
}

// @Summary Delete brand
// @Description Xoá một thương hiệu
// @Security Bearer
// @Tags Brands
// @Produce json
// @Param id path int true "Brand ID"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Router /admin/brands/{id} [delete]
func (c *CatalogController) DeleteBrand(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}

	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	if err := c.brandSvc.Delete(r.Context(), id); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	resp.OK(w, "deleted")
}

// @Summary List brands
// @Description Lấy danh sách thương hiệu (có tìm kiếm và phân trang nhẹ)
// @Tags Brands
// @Produce json
// @Param q query string false "Keyword search"
// @Param limit query int false "Limit" default(20)
// @Param offset query int false "Offset"
// @Success 200 {object} resp.Envelope{data=api.BrandListResponse}
// @Failure 500 {object} resp.Envelope
// @Router /brands [get]
func (c *CatalogController) ListBrands(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))

	items, total, err := c.brandSvc.List(r.Context(), q, limit, offset)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	res := make([]api.BrandResponse, len(items))
	for i := range items {
		res[i] = api.ToBrandResponse(items[i])
	}

	resp.OK(w, api.BrandListResponse{
		Data: res,
		Meta: api.PaginationMeta{CurrentPage: 0, PerPage: limit, Total: total, TotalPages: 0},
	})
}

// @Summary Get brand
// @Description Lấy thông tin chi tiết một thương hiệu
// @Tags Brands
// @Produce json
// @Param id path int true "Brand ID"
// @Success 200 {object} resp.Envelope{data=api.BrandResponse}
// @Failure 404 {object} resp.Envelope
// @Router /brands/{id} [get]
func (c *CatalogController) GetBrand(w http.ResponseWriter, r *http.Request) {
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	brand, err := c.brandSvc.GetByID(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "brand not found")
		return
	}

	resp.OK(w, api.ToBrandResponse(brand))
}

// --- Category Handlers ---

// @Summary Create Category
// @Description Create a new category (Shop only)
// @Security Bearer
// @Tags Categories
// @Accept json
// @Produce json
// @Param body body api.CreateCategoryRequest true "Category data"
// @Success 201 {object} resp.Envelope{data=api.CategoryResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Router /categories [post]
func (c *CatalogController) CreateCategory(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	var req api.CreateCategoryRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}
	category, err := c.categorySvc.CreateCategory(r.Context(), req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.Created(w, toCategoryResponse(category))
}

// @Summary Get Category
// @Description Get a category by ID
// @Tags Categories
// @Produce json
// @Param id path int true "Category ID"
// @Success 200 {object} resp.Envelope{data=api.CategoryResponse}
// @Failure 404 {object} resp.Envelope
// @Router /categories/{id} [get]
func (c *CatalogController) GetCategory(w http.ResponseWriter, r *http.Request) {
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	category, err := c.categorySvc.GetCategory(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "category not found")
		return
	}
	resp.OK(w, toCategoryResponse(category))
}

// @Summary List Categories
// @Description Get all categories
// @Tags Categories
// @Produce json
// @Success 200 {object} resp.Envelope{data=[]api.CategoryResponse}
// @Router /categories [get]
func (c *CatalogController) ListCategories(w http.ResponseWriter, r *http.Request) {
	categories, err := c.categorySvc.ListCategories(r.Context())
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	var res []api.CategoryResponse
	for _, cat := range categories {
		res = append(res, *toCategoryResponse(cat))
	}
	resp.OK(w, res)
}

// @Summary Update Category
// @Description Update a category (Shop only)
// @Security Bearer
// @Tags Categories
// @Accept json
// @Produce json
// @Param id path int true "Category ID"
// @Param body body api.UpdateCategoryRequest true "Category data"
// @Success 200 {object} resp.Envelope{data=api.CategoryResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /categories/{id} [put]
func (c *CatalogController) UpdateCategory(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	var req api.UpdateCategoryRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}
	category, err := c.categorySvc.UpdateCategory(r.Context(), id, req)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			resp.Error(w, http.StatusNotFound, "category not found")
		} else {
			resp.Error(w, http.StatusBadRequest, err.Error())
		}
		return
	}
	resp.OK(w, toCategoryResponse(category))
}

// @Summary Delete Category
// @Description Delete a category (Shop only)
// @Security Bearer
// @Tags Categories
// @Produce json
// @Param id path int true "Category ID"
// @Success 200 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /categories/{id} [delete]
func (c *CatalogController) DeleteCategory(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	if err := c.categorySvc.DeleteCategory(r.Context(), id); err != nil {
		resp.Error(w, http.StatusNotFound, "category not found or could not be deleted")
		return
	}
	resp.OK(w, "category deleted successfully")
}

// --- Style Handlers ---

// @Summary Create Style
// @Description Create a new style (Shop only)
// @Security Bearer
// @Tags Styles
// @Accept json
// @Produce json
// @Param body body api.CreateStyleRequest true "Style data"
// @Success 201 {object} resp.Envelope{data=api.StyleResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Router /styles [post]
func (c *CatalogController) CreateStyle(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	var req api.CreateStyleRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}
	style, err := c.styleSvc.CreateStyle(r.Context(), req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.Created(w, toStyleResponse(style))
}

// @Summary Get Style
// @Description Get a style by ID
// @Tags Styles
// @Produce json
// @Param id path int true "Style ID"
// @Success 200 {object} resp.Envelope{data=api.StyleResponse}
// @Failure 404 {object} resp.Envelope
// @Router /styles/{id} [get]
func (c *CatalogController) GetStyle(w http.ResponseWriter, r *http.Request) {
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	style, err := c.styleSvc.GetStyle(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "style not found")
		return
	}
	resp.OK(w, toStyleResponse(style))
}

// @Summary List Styles
// @Description Get all styles
// @Tags Styles
// @Produce json
// @Success 200 {object} resp.Envelope{data=[]api.StyleResponse}
// @Router /styles [get]
func (c *CatalogController) ListStyles(w http.ResponseWriter, r *http.Request) {
	styles, err := c.styleSvc.ListStyles(r.Context())
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	var res []api.StyleResponse
	for _, s := range styles {
		res = append(res, *toStyleResponse(s))
	}
	resp.OK(w, res)
}

// @Summary Update Style
// @Description Update a style (Shop only)
// @Security Bearer
// @Tags Styles
// @Accept json
// @Produce json
// @Param id path int true "Style ID"
// @Param body body api.UpdateStyleRequest true "Style data"
// @Success 200 {object} resp.Envelope{data=api.StyleResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /styles/{id} [put]
func (c *CatalogController) UpdateStyle(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	var req api.UpdateStyleRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}
	style, err := c.styleSvc.UpdateStyle(r.Context(), id, req)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			resp.Error(w, http.StatusNotFound, "style not found")
		} else {
			resp.Error(w, http.StatusBadRequest, err.Error())
		}
		return
	}
	resp.OK(w, toStyleResponse(style))
}

// @Summary Delete Style
// @Description Delete a style (Shop only)
// @Security Bearer
// @Tags Styles
// @Produce json
// @Param id path int true "Style ID"
// @Success 200 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /styles/{id} [delete]
func (c *CatalogController) DeleteStyle(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	if err := c.styleSvc.DeleteStyle(r.Context(), id); err != nil {
		resp.Error(w, http.StatusNotFound, "style not found or could not be deleted")
		return
	}
	resp.OK(w, "style deleted successfully")
}

// --- Product Handlers ---

// @Summary Create basic product (DRAFT)
// @Description Bước 1: Tạo sản phẩm ở trạng thái DRAFT với thông tin cơ bản và ảnh đại diện tải lên cùng (img_url). Giá sau giảm sẽ được tính tự động từ price và discount_pct.
// @Security Bearer
// @Tags Products
// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Tên sản phẩm"
// @Param price formData number true "Giá ban đầu"
// @Param discount_pct formData integer false "% giảm giá (0..100)"
// @Param brand_id formData int false "ID thương hiệu"
// @Param category_ids formData []int false "Danh sách category id (chọn nhiều)" collectionFormat(multi)
// @Param style_ids formData []int false "Danh sách style id (chọn nhiều)" collectionFormat(multi)
// @Param is_hot_trend formData boolean false "Hot trend"
// @Param age_range formData string false "Độ tuổi"
// @Param description formData string false "Mô tả"
// @Param img_url formData file true "Ảnh đại diện (.jpg/.jpeg/.png/.gif)"
// @Success 201 {object} resp.Envelope{data=api.ProductDetailResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Router /admin/products/basic [post]
func (c *CatalogController) CreateProductBasic(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse form data")
		return
	}
	var p api.BasicProductPayload
	// Parse individual fields (no JSON payload)
	p.Name = strings.TrimSpace(r.FormValue("name"))
	if p.Name == "" {
		resp.Error(w, http.StatusBadRequest, "name is required")
		return
	}
	if v := strings.TrimSpace(r.FormValue("price")); v != "" {
		if fv, err := strconv.ParseFloat(v, 64); err == nil {
			p.Price = fv
		} else {
			resp.Error(w, http.StatusBadRequest, "invalid price")
			return
		}
	} else {
		resp.Error(w, http.StatusBadRequest, "price is required")
		return
	}
	if v := strings.TrimSpace(r.FormValue("discount_pct")); v != "" {
		if iv, err := strconv.Atoi(v); err == nil {
			p.DiscountPct = iv
		}
	}
	if v := strings.TrimSpace(r.FormValue("brand_id")); v != "" {
		if iv, err := strconv.Atoi(v); err == nil {
			p.BrandID = uint(iv)
		}
	}
	for _, s := range r.Form["category_ids"] {
		if iv, err := strconv.Atoi(strings.TrimSpace(s)); err == nil {
			p.CategoryIDs = append(p.CategoryIDs, uint(iv))
		}
	}
	for _, s := range r.Form["style_ids"] {
		if iv, err := strconv.Atoi(strings.TrimSpace(s)); err == nil {
			p.StyleIDs = append(p.StyleIDs, uint(iv))
		}
	}
	if v := strings.TrimSpace(r.FormValue("is_hot_trend")); v != "" {
		p.IsHotTrend = (strings.ToLower(v) == "true" || v == "1")
	}
	p.AgeRange = r.FormValue("age_range")
	p.Description = r.FormValue("description")

	file, header, err := r.FormFile("img_url")
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "img_url is required")
		return
	}
	defer file.Close()
	if err := validation.ValidateImageFile(header); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	imgURL, err := saveProductMainImage(file, header)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to save image")
		return
	}
	prod := &catalogEntities.Product{
		Name:        p.Name,
		Price:       p.Price,
		DiscountPct: p.DiscountPct,
		BrandID:     &p.BrandID,
		PriceAfter:  services.ComputePriceAfter(p.Price, p.DiscountPct),
		AgeRange:    p.AgeRange,
		Description: p.Description,
		IsHotTrend:  p.IsHotTrend,
		Status:      "DRAFT",
		ImageURL:    imgURL,
	}
	if p.BrandID != 0 {
		prod.BrandID = &p.BrandID
	}
	if err := c.prodRepo.Create(r.Context(), prod); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if len(p.CategoryIDs) > 0 {
		_ = c.productSvc.AssignCategoriesToProduct(r.Context(), prod.ID, p.CategoryIDs)
	}
	if len(p.StyleIDs) > 0 {
		_ = c.productSvc.AssignStylesToProduct(r.Context(), prod.ID, p.StyleIDs)
	}
	final, err := c.productSvc.GetProduct(r.Context(), prod.ID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to fetch product")
		return
	}
	resp.Created(w, api.ToProductDetailResponse(final))
}

// @Summary Replace variants/colors/images and finalize product
// @Description Bước 2: Xóa toàn bộ biến thể/màu/ảnh cũ và tạo mới từ form-data; trạng thái chuyển ACTIVE/INACTIVE theo tổng tồn kho.\n\nCách gửi:\n- payload (JSON string):\n  {\n    "colors": [ { "hex": "#FF0000", "image_keys": ["color_0_images"] }, { "hex": "#0000FF", "image_keys": ["color_1_images"] } ],\n    "variants": [ { "color_hex": "#FF0000", "size_code": "S", "stock": 10, "sku": "RED-S-001" }, { "color_hex": "#0000FF", "size_code": "M", "stock": 5 } ]\n  }\n- color_{i}_images: tập ảnh cho màu thứ i (multi files).\n- size hợp lệ: S, M, L, XL, 2XL. SKU có thể bỏ trống, BE sẽ tự sinh nếu thiếu.
// @Security Bearer
// @Tags Products
// @Accept multipart/form-data
// @Produce json
// @Param id path int true "Product ID"
// @Param payload formData string true "JSON payload (colors, variants)"
// @Param color_0_images formData file false "Ảnh cho màu index 0 (gửi nhiều file)"
// @Param color_1_images formData file false "Ảnh cho màu index 1 (gửi nhiều file)"
// @Param color_2_images formData file false "Ảnh cho màu index 2 (gửi nhiều file)"
// @Success 200 {object} resp.Envelope{data=api.ProductDetailResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 409 {object} resp.Envelope
// @Router /admin/products/{id}/variants [post]
func (c *CatalogController) UpsertVariantsAndFinalize(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	productID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	if err := r.ParseMultipartForm(64 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse form data")
		return
	}
	payloadStr := r.FormValue("payload")
	var vp api.VariantsPayload
	if err := json.Unmarshal([]byte(payloadStr), &vp); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid payload")
		return
	}
	hexRe := regexp.MustCompile(`^#[0-9a-fA-F]{6}$`)
	prod, err := c.productSvc.GetProduct(r.Context(), productID)
	if err != nil || prod == nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}
	if strings.ToUpper(prod.Status) != "DRAFT" {
		resp.Error(w, http.StatusConflict, "product is not in DRAFT state")
		return
	}
	// hard replace: delete old variants, color images, and colors
	tx := c.db.WithContext(r.Context()).Begin()
	var colorIDs []uint
	if err := tx.Where("product_id = ?", productID).Delete(&repositories.ProductVariantModel{}).Error; err != nil {
		tx.Rollback()
		resp.Error(w, http.StatusInternalServerError, "failed to clear variants")
		return
	}
	if err := tx.Model(&repositories.ProductColorModel{}).Where("product_id = ?", productID).Pluck("id", &colorIDs).Error; err != nil {
		tx.Rollback()
		resp.Error(w, http.StatusInternalServerError, "failed to load colors")
		return
	}
	if len(colorIDs) > 0 {
		if err := tx.Where("product_color_id IN ?", colorIDs).Delete(&repositories.ProductColorImageModel{}).Error; err != nil {
			tx.Rollback()
			resp.Error(w, http.StatusInternalServerError, "failed to clear color images")
			return
		}
	}
	if err := tx.Where("product_id = ?", productID).Delete(&repositories.ProductColorModel{}).Error; err != nil {
		tx.Rollback()
		resp.Error(w, http.StatusInternalServerError, "failed to clear colors")
		return
	}
	if err := tx.Commit().Error; err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to reset product variants")
		return
	}
	// Create new colors & images
	colorIDByHex := map[string]uint{}
	for _, cp := range vp.Colors {
		hex := strings.ToUpper(strings.TrimSpace(cp.Hex))
		if !hexRe.MatchString(hex) {
			resp.Error(w, http.StatusBadRequest, "invalid color_hex: "+cp.Hex)
			return
		}
		col := &catalogEntities.ProductColor{ProductID: productID, ColorHex: hex, ColorName: services.MapColorNameFromHex(hex)}
		if err := c.prodColorRepo.Create(r.Context(), col); err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		colorIDByHex[hex] = col.ID
		images := make([]catalogEntities.ProductColorImage, 0)
		imgIdx := 0
		if r.MultipartForm != nil {
			for _, key := range cp.ImageKeys {
				fileHeaders := r.MultipartForm.File[key]
				for _, fh := range fileHeaders {
					f, err := fh.Open()
					if err != nil {
						continue
					}
					defer f.Close()
					if err := validation.ValidateImageFile(fh); err != nil {
						resp.Error(w, http.StatusBadRequest, err.Error())
						return
					}
					url, err := saveColorImageFile(productID, col.ID, f, fh)
					if err != nil {
						resp.Error(w, http.StatusInternalServerError, "failed to save color image")
						return
					}
					images = append(images, catalogEntities.ProductColorImage{ProductColorID: col.ID, ImageURL: url, SortOrder: imgIdx})
					imgIdx++
				}
			}
		}
		if err := c.prodColorImageRepo.CreateMany(r.Context(), images); err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
	}
	// Create variants
	allowed := map[string]struct{}{"S": {}, "M": {}, "L": {}, "XL": {}, "2XL": {}}
	upserts := make([]services.ProductVariantUpsert, 0, len(vp.Variants))
	seq := 0
	for _, v := range vp.Variants {
		hex := strings.ToUpper(strings.TrimSpace(v.ColorHex))
		cid, ok := colorIDByHex[hex]
		if !ok {
			resp.Error(w, http.StatusBadRequest, "color not found: "+hex)
			return
		}
		size := strings.ToUpper(strings.TrimSpace(v.SizeCode))
		if _, ok := allowed[size]; !ok {
			resp.Error(w, http.StatusBadRequest, "invalid size_code: "+size)
			return
		}
		if v.Stock < 0 {
			resp.Error(w, http.StatusBadRequest, "stock must be >= 0")
			return
		}
		sku := strings.TrimSpace(v.Sku)
		if sku == "" {
			seq++
			sku = generateSKU(productID, hex, size, seq)
		}
		upserts = append(upserts, services.ProductVariantUpsert{ProductColorID: cid, SizeCode: size, Stock: v.Stock, Sku: sku})
	}
	total, err := c.prodVariantRepo.UpsertMany(r.Context(), productID, upserts)
	if err != nil {
		msg := strings.ToLower(err.Error())
		if strings.Contains(msg, "duplicate") || strings.Contains(msg, "unique") {
			resp.Error(w, http.StatusBadRequest, "sku duplicated or color-size duplicated")
			return
		}
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	_ = c.prodStatsRepo.UpsertTotalStock(r.Context(), productID, total)
	// finalize
	var cnt int64
	if err := c.db.WithContext(r.Context()).Model(&repositories.ProductVariantModel{}).Where("product_id = ?", productID).Count(&cnt).Error; err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to check variants")
		return
	}
	if cnt == 0 {
		resp.Error(w, http.StatusBadRequest, "cannot finalize without variants")
		return
	}
	prod, err = c.productSvc.GetProduct(r.Context(), productID)
	if err != nil || prod == nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}
	if total > 0 {
		prod.Status = "ACTIVE"
	} else {
		prod.Status = "INACTIVE"
	}
	if err := c.prodRepo.Update(r.Context(), prod); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	final, _ := c.productSvc.GetProduct(r.Context(), productID)
	resp.OK(w, api.ToProductDetailResponse(final))
}

// generateSKU tạo SKU theo rule {productId}-{HEX}-{SIZE}-{seq}
// HEX đã loại bỏ ký tự '#', viết hoa; SIZE viết hoa; seq là số tăng dần trong 1 request
func generateSKU(productID uint, hex string, size string, seq int) string {
	hex = strings.TrimPrefix(strings.ToUpper(strings.TrimSpace(hex)), "#")
	size = strings.ToUpper(strings.TrimSpace(size))
	return fmt.Sprintf("%d-%s-%s-%03d", productID, hex, size, seq)
}

func saveProductMainImage(src multipart.File, header *multipart.FileHeader) (string, error) {
	ext := filepath.Ext(header.Filename)
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	uploadDir := "uploads/products"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return "", err
	}
	dstPath := filepath.Join(uploadDir, filename)
	dst, err := os.Create(dstPath)
	if err != nil {
		return "", err
	}
	defer dst.Close()
	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}
	return "/" + filepath.ToSlash(filepath.Join(uploadDir, filename)), nil
}

func saveColorImageFile(productID, colorID uint, src multipart.File, header *multipart.FileHeader) (string, error) {
	ext := filepath.Ext(header.Filename)
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	uploadDir := filepath.Join("uploads", "products", fmt.Sprintf("%d", productID), fmt.Sprintf("%d", colorID))
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return "", err
	}
	dstPath := filepath.Join(uploadDir, filename)
	dst, err := os.Create(dstPath)
	if err != nil {
		return "", err
	}
	defer dst.Close()
	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}
	return "/" + filepath.ToSlash(filepath.Join(uploadDir, filename)), nil
}

// @Summary Get Product
// @Description Get a product by ID with full details
// @Tags Products
// @Produce json
// @Param id path int true "Product ID"
// @Success 200 {object} resp.Envelope{data=api.ProductDetailResponse}
// @Failure 404 {object} resp.Envelope
// @Router /products/{id} [get]
func (c *CatalogController) GetProduct(w http.ResponseWriter, r *http.Request) {
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	product, err := c.productSvc.GetProduct(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}
	res := api.ToProductDetailResponse(product)
	// attach stats if available
	var stats repositories.ProductStatsModel
	if err := c.db.WithContext(r.Context()).Where("product_id = ?", id).First(&stats).Error; err == nil {
		res.TotalStock = stats.TotalStock
		res.SoldCount = stats.SoldCount
		res.RatingAvg = stats.RatingAvg
	}
	resp.OK(w, res)
}

// @Summary List Products
// @Description Lấy danh sách sản phẩm với phân trang và bộ lọc (dành cho mobile)
// @Description Filter options: `all`, `hot`, `new`, `best`, `recommend`
// @Tags Products
// @Accept json
// @Produce json
// @Param body body api.ProductListRequest false "Tùy chọn phân trang và bộ lọc"
// @Success 200 {object} resp.Envelope{data=api.PaginatedProductResponse}
// @Router /products/list [post]
func (c *CatalogController) ListProducts(w http.ResponseWriter, r *http.Request) {
	var req api.ProductListRequest
	if r.Body != http.NoBody {
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil && err != io.EOF {
			resp.Error(w, http.StatusBadRequest, "invalid request body")
			return
		}
	}
	products, total, err := c.productSvc.ListProductsPaginated(r.Context(), req.Filter, req.Page, req.Limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	productSummaries := make([]api.ProductSummaryResponse, len(products))
	for i, p := range products {
		productSummaries[i] = toProductSummaryResponse(p)
	}
	finalLimit := req.Limit
	if finalLimit <= 0 {
		finalLimit = 20
	}
	totalPages := 0
	if total > 0 {
		totalPages = int(total-1)/finalLimit + 1
	}
	resp.OK(w, api.PaginatedProductResponse{Data: productSummaries, Meta: api.PaginationMeta{CurrentPage: req.Page, PerPage: finalLimit, Total: total, TotalPages: totalPages}})
}

// @Summary Delete Product
// @Description Delete a product (Shop only)
// @Security Bearer
// @Tags Products
// @Produce json
// @Param id path int true "Product ID"
// @Success 200 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /products/{id} [delete]
func (c *CatalogController) DeleteProduct(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	if err := c.productSvc.DeleteProduct(r.Context(), id); err != nil {
		resp.Error(w, http.StatusNotFound, "product not found or could not be deleted")
		return
	}
	resp.OK(w, "product deleted successfully")
}

// --- Response Mappers ---

func toCategoryResponse(cat *catalogEntities.Category) *api.CategoryResponse {
	return &api.CategoryResponse{ID: cat.ID, Name: cat.Name}
}

func toStyleResponse(style *catalogEntities.Style) *api.StyleResponse {
	return &api.StyleResponse{ID: style.ID, Name: style.Name}
}

// toProductSummaryResponse converts entity Product to DTO for product list
func toProductSummaryResponse(p *catalogEntities.Product) api.ProductSummaryResponse {
	return api.ProductSummaryResponse{ProductAbstract: api.ProductAbstract{
		ID:          p.ID,
		Name:        p.Name,
		Price:       p.Price,
		DiscountPct: p.DiscountPct,
		PriceAfter:  p.PriceAfter,
		ImageURL:    p.ImageURL,
	}}
}
