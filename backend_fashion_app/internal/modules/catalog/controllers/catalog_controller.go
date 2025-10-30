package controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/auth/entities"
	"myfashion/internal/modules/catalog/api"
	catalogEntities "myfashion/internal/modules/catalog/entities"
	"myfashion/internal/modules/catalog/repositories"
	"myfashion/internal/modules/catalog/services"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// @tags Catalog
type CatalogController struct {
	svc *services.CatalogService
}

func NewCatalogController(db *gorm.DB) *CatalogController {
	catRepo := repositories.NewCategoryGormRepo(db)
	styleRepo := repositories.NewStyleGormRepo(db)
	prodRepo := repositories.NewProductGormRepo(db)
	svc := services.NewCatalogService(catRepo, styleRepo, prodRepo)
	return &CatalogController{svc: svc}
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

func (c *CatalogController) saveUploadedFile(file *multipart.FileHeader) (string, error) {
	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	if err := os.MkdirAll("uploads/products", os.ModePerm); err != nil {
		return "", err
	}

	dstPath := filepath.Join("uploads/products", filename)
	dst, err := os.Create(dstPath)
	if err != nil {
		return "", err
	}
	defer dst.Close()

	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}

	return "/uploads/products/" + filename, nil
}

// --- Category Handlers ---

// @Summary Create Category
// @Description Create a new category (Shop only)
// @Security Bearer
// @Tags Catalog
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
	category, err := c.svc.CreateCategory(r.Context(), req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.Created(w, toCategoryResponse(category))
}

// @Summary Get Category
// @Description Get a category by ID
// @Tags Catalog
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
	category, err := c.svc.GetCategory(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "category not found")
		return
	}
	resp.OK(w, toCategoryResponse(category))
}

// @Summary List Categories
// @Description Get all categories
// @Tags Catalog
// @Produce json
// @Success 200 {object} resp.Envelope{data=[]api.CategoryResponse}
// @Router /categories [get]
func (c *CatalogController) ListCategories(w http.ResponseWriter, r *http.Request) {
	categories, err := c.svc.ListCategories(r.Context())
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
// @Tags Catalog
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
	category, err := c.svc.UpdateCategory(r.Context(), id, req)
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
// @Tags Catalog
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
	if err := c.svc.DeleteCategory(r.Context(), id); err != nil {
		resp.Error(w, http.StatusNotFound, "category not found or could not be deleted")
		return
	}
	resp.OK(w, "category deleted successfully")
}

// --- Style Handlers ---

// @Summary Create Style
// @Description Create a new style (Shop only)
// @Security Bearer
// @Tags Catalog
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
	style, err := c.svc.CreateStyle(r.Context(), req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.Created(w, toStyleResponse(style))
}

// @Summary Get Style
// @Description Get a style by ID
// @Tags Catalog
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
	style, err := c.svc.GetStyle(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "style not found")
		return
	}
	resp.OK(w, toStyleResponse(style))
}

// @Summary List Styles
// @Description Get all styles
// @Tags Catalog
// @Produce json
// @Success 200 {object} resp.Envelope{data=[]api.StyleResponse}
// @Router /styles [get]
func (c *CatalogController) ListStyles(w http.ResponseWriter, r *http.Request) {
	styles, err := c.svc.ListStyles(r.Context())
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
// @Tags Catalog
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
	style, err := c.svc.UpdateStyle(r.Context(), id, req)
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
// @Tags Catalog
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
	if err := c.svc.DeleteStyle(r.Context(), id); err != nil {
		resp.Error(w, http.StatusNotFound, "style not found or could not be deleted")
		return
	}
	resp.OK(w, "style deleted successfully")
}

// --- Product Handlers ---

// @Summary Create Product
// @Description Create a new product with images (Shop only). Use multipart/form-data. For 'other_images', you can select multiple files at once or add the field multiple times in your HTTP client.
// @Security Bearer
// @Tags Catalog
// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Product Name"
// @Param category_ids formData string true "Comma-separated category IDs (e.g., '1,2')"
// @Param style_ids formData string true "Comma-separated style IDs (e.g., '3,4')"
// @Param price formData number true "Product Price"
// @Param discount_pct formData integer false "Discount Percentage"
// @Param color formData string false "Product Color"
// @Param age_range formData string false "Age Range"
// @Param description formData string false "Product Description"
// @Param background_image formData file true "Background image for the product (image_url)"
// @Param other_images formData []file false "Other related images (can upload multiple files)" collectionFormat(multi)
// @Success 201 {object} resp.Envelope{data=api.ProductResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Router /products [post]
func (c *CatalogController) CreateProduct(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}

	// 32 MB max memory
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse multipart form")
		return
	}

	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)
	discount, _ := strconv.Atoi(r.FormValue("discount_pct"))
	stock, _ := strconv.Atoi(r.FormValue("stock"))

	req := api.CreateProductRequest{
		Name:        r.FormValue("name"),
		CategoryIDs: r.FormValue("category_ids"),
		StyleIDs:    r.FormValue("style_ids"),
		Price:       price,
		DiscountPct: discount,
		Stock:       stock,
		Color:       r.FormValue("color"),
		AgeRange:    r.FormValue("age_range"),
		Description: r.FormValue("description"),
	}

	// Create product first to get an ID
	product, err := c.svc.CreateProduct(r.Context(), req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// --- Image Handling ---
	form := r.MultipartForm
	var backgroundURL string
	var otherImageURLs []string

	// Handle background image
	bgImages, ok := form.File["background_image"]
	if !ok || len(bgImages) == 0 {
		resp.Error(w, http.StatusBadRequest, "background_image is required")
		return
	}
	bgURL, err := c.saveUploadedFile(bgImages[0])
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to save background image")
		return
	}
	backgroundURL = bgURL

	// Handle other images
	otherImages, ok := form.File["other_images"]
	if ok {
		for _, fileHeader := range otherImages {
			url, err := c.saveUploadedFile(fileHeader)
			if err != nil {
				fmt.Printf("failed to save file %s: %v\n", fileHeader.Filename, err)
				continue
			}
			otherImageURLs = append(otherImageURLs, url)
		}
	}

	// Save other images to the database
	if len(otherImageURLs) > 0 {
		_, err := c.svc.AddProductImages(r.Context(), product.ID, otherImageURLs)
		if err != nil {
			resp.Error(w, http.StatusInternalServerError, "failed to save product images to db")
			return
		}
	}

	// Update product with the background image URL
	finalProduct, err := c.svc.UpdateProduct(r.Context(), product.ID, api.UpdateProductRequest{ImageURL: backgroundURL})
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to update product with image url")
		return
	}

	resp.Created(w, toProductResponse(finalProduct))
}

// @Summary Get Product
// @Description Get a product by ID
// @Tags Catalog
// @Produce json
// @Param id path int true "Product ID"
// @Success 200 {object} resp.Envelope{data=api.ProductResponse}
// @Failure 404 {object} resp.Envelope
// @Router /products/{id} [get]
func (c *CatalogController) GetProduct(w http.ResponseWriter, r *http.Request) {
	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	product, err := c.svc.GetProduct(r.Context(), id)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}

	resp.OK(w, toProductResponse(product))
}

// @Summary List Products
// @Description Get all products with pagination
// @Tags Catalog
// @Produce json
// @Param page query int false "Page number (default: 1)"
// @Param limit query int false "Items per page (default: 20, max: 100)"
// @Success 200 {object} resp.Envelope{data=api.PaginatedProductResponse}
// @Router /products [get]
func (c *CatalogController) ListProducts(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	pageStr := r.URL.Query().Get("page")
	limitStr := r.URL.Query().Get("limit")

	page := 1
	limit := 20

	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}

	}

	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	// Get paginated products
	products, total, err := c.svc.ListProductsPaginated(r.Context(), page, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Convert to response DTOs
	var productResponses []api.ProductResponse
	for _, p := range products {
		productResponses = append(productResponses, *toProductResponse(p))
	}

	// Calculate total pages
	totalPages := int(total) / limit
	if int(total)%limit != 0 {
		totalPages++
	}

	// Build paginated response
	paginatedResponse := api.PaginatedProductResponse{
		Data: productResponses,
		Meta: api.PaginationMeta{
			CurrentPage: page,
			PerPage:     limit,
			Total:       total,
			TotalPages:  totalPages,
		},
	}

	resp.OK(w, paginatedResponse)
}

// @Summary Update Product
// @Description Update a product (Shop only). Use multipart/form-data.
// @Security Bearer
// @Tags Catalog
// @Accept multipart/form-data
// @Produce json
// @Param id path int true "Product ID"
// @Param name formData string false "Product Name"
// @Param category_ids formData string false "Comma-separated category IDs"
// @Param style_ids formData string false "Comma-separated style IDs"
// @Param price formData number false "Product Price"
// @Param discount_pct formData integer false "Discount Percentage"
// @Param color formData string false "Product Color"
// @Param age_range formData string false "Age Range"
// @Param description formData string false "Product Description"
// @Success 200 {object} resp.Envelope{data=api.ProductResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /products/{id} [put]
func (c *CatalogController) UpdateProduct(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}

	id, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	// 32 MB max memory
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse multipart form")
		return
	}

	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)

	// Only parse discount_pct if it's provided in the form
	var discountPtr *int
	if discountStr := r.FormValue("discount_pct"); discountStr != "" {
		discount, err := strconv.Atoi(discountStr)
		if err == nil {
			discountPtr = &discount
		}
	}

	// Only parse stock if it's provided in the form
	var stockPtr *int
	if stockStr := r.FormValue("stock"); stockStr != "" {
		stock, err := strconv.Atoi(stockStr)
		if err == nil {
			stockPtr = &stock
		}
	}

	req := api.UpdateProductRequest{
		Name:        r.FormValue("name"),
		CategoryIDs: r.FormValue("category_ids"),
		StyleIDs:    r.FormValue("style_ids"),
		Price:       price,
		DiscountPct: discountPtr,
		Stock:       stockPtr,
		Color:       r.FormValue("color"),
		AgeRange:    r.FormValue("age_range"),
		Description: r.FormValue("description"),
	}

	product, err := c.svc.UpdateProduct(r.Context(), id, req)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			resp.Error(w, http.StatusNotFound, "product not found")
		} else {
			resp.Error(w, http.StatusBadRequest, err.Error())
		}
		return
	}

	resp.OK(w, toProductResponse(product))
}

// @Summary Delete Product
// @Description Delete a product (Shop only)
// @Security Bearer
// @Tags Catalog
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

	if err := c.svc.DeleteProduct(r.Context(), id); err != nil {
		resp.Error(w, http.StatusNotFound, "product not found or could not be deleted")
		return
	}

	resp.OK(w, "product deleted successfully")
}

// --- Response Mappers ---

func toCategoryResponse(cat *catalogEntities.Category) *api.CategoryResponse {
	return &api.CategoryResponse{
		ID:   cat.ID,
		Name: cat.Name,
	}
}

func toStyleResponse(style *catalogEntities.Style) *api.StyleResponse {
	return &api.StyleResponse{
		ID:   style.ID,
		Name: style.Name,
	}
}

func toProductImageResponse(img *catalogEntities.ProductImage) *api.ProductImageResponse {
	return &api.ProductImageResponse{
		ID:  img.ID,
		URL: img.URL,
	}
}

func toProductResponse(p *catalogEntities.Product) *api.ProductResponse {
	images := make([]api.ProductImageResponse, len(p.Images))
	for i, img := range p.Images {
		images[i] = *toProductImageResponse(&img)
	}

	categories := make([]api.CategoryResponse, len(p.Categories))
	for i, cat := range p.Categories {
		categories[i] = *toCategoryResponse(&cat)
	}

	styles := make([]api.StyleResponse, len(p.Styles))
	for i, s := range p.Styles {
		styles[i] = *toStyleResponse(&s)
	}

	return &api.ProductResponse{
		ID:          p.ID,
		Name:        p.Name,
		Price:       p.Price,
		DiscountPct: p.DiscountPct,
		PriceAfter:  p.PriceAfter,
		Stock:       p.Stock,
		Color:       p.Color,
		AgeRange:    p.AgeRange,
		Description: p.Description,
		ImageURL:    p.ImageURL,
		Categories:  categories,
		Styles:      styles,
		Images:      images,
		CreatedAt:   p.CreatedAt,
		UpdatedAt:   p.UpdatedAt,
	}
}
