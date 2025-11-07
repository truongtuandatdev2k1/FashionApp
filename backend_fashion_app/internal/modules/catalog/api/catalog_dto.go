package api

import "time"

// --- Pagination DTOs ---

type ProductListRequest struct {
	Page   int    `form:"page" json:"page,omitempty"`
	Limit  int    `form:"limit" json:"limit,omitempty"`
	Filter string `form:"filter" json:"filter,omitempty"` // all, bestseller, new, hottrend
}

type PaginationMeta struct {
	CurrentPage int   `json:"current_page"`
	PerPage     int   `json:"per_page"`
	Total       int64 `json:"total"`
	TotalPages  int   `json:"total_pages"`
}

// ProductSummaryResponse chứa thông tin rút gọn của sản phẩm cho danh sách
type ProductSummaryResponse struct {
	ID          uint    `json:"id"`
	Name        string  `json:"name"`
	Price       float64 `json:"price"`
	DiscountPct int     `json:"discount_pct"`
	PriceAfter  float64 `json:"price_after"`
	ImageURL    string  `json:"image_url"`
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

// --- Product DTOs ---

type ProductImageResponse struct {
	ID  uint   `json:"id"`
	URL string `json:"url"`
}

type ProductResponse struct {
	ID          uint                   `json:"id"`
	Name        string                 `json:"name"`
	Price       float64                `json:"price"`
	DiscountPct int                    `json:"discount_pct"`
	PriceAfter  float64                `json:"price_after"`
	Stock       int                    `json:"stock"`
	Color       string                 `json:"color"`
	AgeRange    string                 `json:"age_range"`
	Description string                 `json:"description"`
	ImageURL    string                 `json:"image_url"`
	Categories  []CategoryResponse     `json:"categories"`
	Styles      []StyleResponse        `json:"styles"`
	Images      []ProductImageResponse `json:"images"`
	CreatedAt   time.Time              `json:"created_at"`
	UpdatedAt   time.Time              `json:"updated_at"`
}

// CreateProductRequest uses form binding for multipart/form-data
// CategoryIDs and StyleIDs are comma-separated strings
// e.g., "1,2,3"
type CreateProductRequest struct {
	Name               string  `form:"name" binding:"required"`
	CategoryIDs        string  `form:"category_ids" binding:"required"`
	StyleIDs           string  `form:"style_ids" binding:"required"`
	Price              float64 `form:"price" binding:"required,gt=0"`
	DiscountPct        int     `form:"discount_pct" binding:"omitempty,gte=0,lte=100"`
	Stock              int     `form:"stock" binding:"required,gte=0"`
	Color              string  `form:"color"`
	AgeRange           string  `form:"age_range"`
	Description        string  `form:"description"`
	IsHotTrend         bool    `form:"is_hot_trend"`
	BackgroundImageURL string  `form:"background_image_url"` // Link ảnh nền
	OtherImageURLs     string  `form:"other_image_urls"`     // Các link ảnh khác, cách nhau bằng dấu phẩy
}

// UpdateProductRequest uses form binding for multipart/form-data
type UpdateProductRequest struct {
	Name               string  `form:"name"`
	CategoryIDs        string  `form:"category_ids"`
	StyleIDs           string  `form:"style_ids"`
	Price              float64 `form:"price" binding:"omitempty,gt=0"`
	DiscountPct        *int    `form:"discount_pct" binding:"omitempty,gte=0,lte=100"`
	Stock              *int    `form:"stock" binding:"omitempty,gte=0"`
	Color              string  `form:"color"`
	AgeRange           string  `form:"age_range"`
	Description        string  `form:"description"`
	IsHotTrend         *bool   `form:"is_hot_trend"`
	ImageURL           string  `form:"image_url"`
	BackgroundImageURL string  `form:"background_image_url"` // Link ảnh nền
	OtherImageURLs     string  `form:"other_image_urls"`     // Các link ảnh khác, cách nhau bằng dấu phẩy
}
