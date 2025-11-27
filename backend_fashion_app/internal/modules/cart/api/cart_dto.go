package api

import "time"

// ========== REQUEST DTOs ==========

// AddToCartRequest - Thêm sản phẩm vào giỏ hàng
type AddToCartRequest struct {
	ProductVariantID uint `json:"product_variant_id" validate:"required,min=1"`
	Quantity         int  `json:"quantity" validate:"required,min=1"`
}

// UpdateCartItemRequest - Cập nhật số lượng sản phẩm trong giỏ
type UpdateCartItemRequest struct {
	Quantity int `json:"quantity" validate:"required,min=1"`
}

// ChangeCartItemVariantRequest - Đổi màu/size của một item trong giỏ
// Ít nhất 1 trong 2 trường phải có. Nếu thiếu trường nào sẽ dùng giá trị hiện tại của item.
type ChangeCartItemVariantRequest struct {
	ColorHex string `json:"color_hex,omitempty"`
	SizeCode string `json:"size_code,omitempty"`
}

// ========== RESPONSE DTOs ==========

// ProductInfo - Thông tin sản phẩm trong giỏ hàng
type ProductInfo struct {
	ProductID    uint    `json:"product_id"`
	VariantID    uint    `json:"variant_id"`
	Name         string  `json:"name"` // Product Name
	SKU          string  `json:"sku"`  // Variant SKU
	Color        string  `json:"color"`
	Size         string  `json:"size"`
	ImageURL     string  `json:"image_url"`     // Can be from Product or Variant
	Stock        int     `json:"stock"`         // Variant Stock
	CurrentPrice float64 `json:"current_price"` // Variant Price
}

// CartItemResponse - Thông tin chi tiết một item trong giỏ hàng
type CartItemResponse struct {
	ID               uint        `json:"id"` // CartItem ID
	ProductVariantID uint        `json:"product_variant_id"`
	Product          ProductInfo `json:"product"`
	Quantity         int         `json:"quantity"`
	PriceSnapshot    float64     `json:"price_snapshot"` // Giá lúc thêm vào giỏ
	CurrentPrice     float64     `json:"current_price"`  // Giá hiện tại
	PriceChanged     bool        `json:"price_changed"`  // Có thay đổi giá không?
	StockIssue       bool        `json:"stock_issue"`    // Số lượng trong giỏ > tồn kho?
	Subtotal         float64     `json:"subtotal"`       // Tổng tiền = quantity * current_price
	CreatedAt        time.Time   `json:"created_at"`
}

// CartResponse - Thông tin giỏ hàng đầy đủ
type CartResponse struct {
	ID          uint               `json:"id"`
	UserID      uint               `json:"user_id"`
	Items       []CartItemResponse `json:"items"`
	TotalItems  int                `json:"total_items"`  // Tổng số sản phẩm (cộng dồn quantity)
	TotalAmount float64            `json:"total_amount"` // Tổng tiền
	HasIssues   bool               `json:"has_issues"`   // Có vấn đề gì không (giá thay đổi, hết hàng...)
	CanCheckout bool               `json:"can_checkout"` // Có thể thanh toán không?
	CreatedAt   time.Time          `json:"created_at"`
	UpdatedAt   time.Time          `json:"updated_at"`
}

// CartSummaryResponse - Tóm tắt giỏ hàng để chuẩn bị thanh toán
type CartSummaryResponse struct {
	Items       []CartItemResponse `json:"items"`
	TotalItems  int                `json:"total_items"`
	TotalAmount float64            `json:"total_amount"`
	CanCheckout bool               `json:"can_checkout"`
	Issues      []string           `json:"issues,omitempty"` // Danh sách các vấn đề (nếu có)
}
