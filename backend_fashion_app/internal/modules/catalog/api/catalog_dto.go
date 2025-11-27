package api

import (
	"myfashion/internal/modules/catalog/entities"
	"time"
)

// --- Brand DTOs ---

type BrandRequest struct {
	Name    string `json:"name" binding:"required"`
	LogoURL string `json:"logo_url,omitempty"`
}

type BrandResponse struct {
	ID        uint      `json:"id"`
	Name      string    `json:"name"`
	LogoURL   string    `json:"logo_url"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func ToBrandResponse(brand *entities.Brand) BrandResponse {
	if brand == nil {
		return BrandResponse{}
	}
	return BrandResponse{
		ID:        brand.ID,
		Name:      brand.Name,
		LogoURL:   brand.LogoURL,
		CreatedAt: brand.CreatedAt,
		UpdatedAt: brand.UpdatedAt,
	}
}

type BrandListResponse struct {
	Data []BrandResponse `json:"data"`
	Meta PaginationMeta  `json:"meta"`
}

// --- Pagination DTOs ---

type ProductListRequest struct {
	Page   int    `json:"page,omitempty"`
	Limit  int    `json:"limit,omitempty"`
	Filter string `json:"filter,omitempty"` // all, bestseller, new, hottrend
}

type PaginationMeta struct {
	CurrentPage int   `json:"current_page"`
	PerPage     int   `json:"per_page"`
	Total       int64 `json:"total"`
	TotalPages  int   `json:"total_pages"`
}

// ProductAbstract contains common product fields for list views.
type ProductAbstract struct {
	ID          uint    `json:"id"`
	Name        string  `json:"name"`
	Price       float64 `json:"price"`
	DiscountPct int     `json:"discount_pct"`
	PriceAfter  float64 `json:"priceAfter"`
	ImageURL    string  `json:"image_url,omitempty"`
}

// ProductSummaryResponse contains summarized product info for lists
type ProductSummaryResponse struct {
	ProductAbstract
}

type PaginatedProductResponse struct {
	Data []ProductSummaryResponse `json:"data"`
	Meta PaginationMeta           `json:"meta"`
}

// --- Category DTOs ---

type CreateCategoryRequest struct {
	Name string `json:"name" binding:"required"`
}

type UpdateCategoryRequest struct {
	Name string `json:"name" binding:"required"`
}

type CategoryResponse struct {
	ID   uint   `json:"id"`
	Name string `json:"name"`
}

// --- Style DTOs ---

type CreateStyleRequest struct {
	Name string `json:"name" binding:"required"`
}

type UpdateStyleRequest struct {
	Name string `json:"name" binding:"required"`
}

type StyleResponse struct {
	ID   uint   `json:"id"`
	Name string `json:"name"`
}

// --- Color DTOs ---

type CreateColorRequest struct {
	Name    string `json:"name" binding:"required"`
	HexCode string `json:"hex_code"`
}

type UpdateColorRequest struct {
	Name    string `json:"name,omitempty"`
	HexCode string `json:"hex_code,omitempty"`
}

type ColorResponse struct {
	ID      uint   `json:"id"`
	Name    string `json:"name"`
	HexCode string `json:"hex_code"`
}

// --- Product DTOs ---

type ProductImageResponse struct {
	ID  uint   `json:"id"`
	URL string `json:"url"`
}

type ProductVariantResponse struct {
	ID        uint                   `json:"id"`
	Price     float64                `json:"price"`
	Stock     int                    `json:"stock"`
	Sku       string                 `json:"sku"`
	ColorName string                 `json:"color_name"`
	ColorHex  string                 `json:"color_hex"`
	SizeCode  string                 `json:"size_code"`
	Images    []ProductImageResponse `json:"images,omitempty"`
}

type ProductColorItem struct {
	ColorName string `json:"color_name"`
	ColorHex  string `json:"color_hex"`
}

type ProductDetailResponse struct {
	ID          uint                     `json:"id"`
	Name        string                   `json:"name"`
	Price       float64                  `json:"price"`
	PriceAfter  float64                  `json:"priceAfter"`
	DiscountPct int                      `json:"discount_pct"`
	Description string                   `json:"description"`
	ImageURL    string                   `json:"image_url,omitempty"`
	Brand       *BrandResponse           `json:"brand"`
	Variants    []ProductVariantResponse `json:"variants"`
	Colors      []ProductColorItem       `json:"colors"`
	Sizes       []string                 `json:"sizes"`
	TotalStock  int                      `json:"total_stock"`
	SoldCount   int                      `json:"sold_count"`
	RatingAvg   float64                  `json:"rating_avg"`
	CreatedAt   time.Time                `json:"created_at"`
	UpdatedAt   time.Time                `json:"updated_at"`
}

func ToProductDetailResponse(product *entities.Product) ProductDetailResponse {
	var brandResponse *BrandResponse
	if product.Brand != nil {
		br := ToBrandResponse(product.Brand)
		brandResponse = &br
	}

	// Variants
	variants := make([]ProductVariantResponse, len(product.Variants))
	for i, v := range product.Variants {
		// map images from product_color_images
		variantImages := make([]ProductImageResponse, 0, len(v.ProductColor.Images))
		for _, im := range v.ProductColor.Images {
			variantImages = append(variantImages, ProductImageResponse{ID: im.ID, URL: im.ImageURL})
		}
		variants[i] = ProductVariantResponse{
			ID:        v.ID,
			Price:     product.PriceAfter,
			Stock:     v.Stock,
			Sku:       v.Sku,
			ColorName: v.ProductColor.ColorName,
			ColorHex:  v.ProductColor.ColorHex,
			SizeCode:  v.SizeCode,
			Images:    variantImages,
		}
	}

	// Colors (unique by hex)
	colorSeen := map[string]bool{}
	colors := make([]ProductColorItem, 0)
	for _, v := range product.Variants {
		hex := v.ProductColor.ColorHex
		if !colorSeen[hex] {
			colorSeen[hex] = true
			colors = append(colors, ProductColorItem{ColorName: v.ProductColor.ColorName, ColorHex: v.ProductColor.ColorHex})
		}
	}

	// Sizes (unique list)
	sizeSeen := map[string]bool{}
	sizes := make([]string, 0)
	for _, v := range product.Variants {
		if !sizeSeen[v.SizeCode] {
			sizeSeen[v.SizeCode] = true
			sizes = append(sizes, v.SizeCode)
		}
	}

	return ProductDetailResponse{
		ID:          product.ID,
		Name:        product.Name,
		Price:       product.Price,
		PriceAfter:  product.PriceAfter,
		DiscountPct: product.DiscountPct,
		Description: product.Description,
		ImageURL:    product.ImageURL,
		Brand:       brandResponse,
		Variants:    variants,
		Colors:      colors,
		Sizes:       sizes,
		CreatedAt:   product.CreatedAt,
		UpdatedAt:   product.UpdatedAt,
	}
}

// --- Step 1 & 2 Payloads ---

// BasicProductPayload is the JSON payload for step 1 (basic info) embedded in multipart/form-data
// Field name in form-data: payload
// main_image is sent as a separate file field
// price_after is computed on server; not part of request

type BasicProductPayload struct {
	Name        string  `json:"name"`
	Price       float64 `json:"price"`
	DiscountPct int     `json:"discount_pct"`
	BrandID     uint    `json:"brand_id"`
	CategoryIDs []uint  `json:"category_ids"`
	StyleIDs    []uint  `json:"style_ids"`
	IsHotTrend  bool    `json:"is_hot_trend"`
	AgeRange    string  `json:"age_range"`
	Description string  `json:"description"`
}

type ColorPayload struct {
	Hex       string   `json:"hex"`
	ImageKeys []string `json:"image_keys"`
}

type VariantSpec struct {
	ColorHex string `json:"color_hex"`
	SizeCode string `json:"size_code"`
	Stock    int    `json:"stock"`
	Sku      string `json:"sku,omitempty"`
}

type VariantsPayload struct {
	Colors   []ColorPayload `json:"colors"`
	Variants []VariantSpec  `json:"variants"`
}
