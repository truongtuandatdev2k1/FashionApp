package api

import "time"

type AdminVariantResponse struct {
	VariantID      uint      `json:"variant_id"`
	ProductID      uint      `json:"product_id"`
	ProductColorID uint      `json:"product_color_id"`
	ColorHex       string    `json:"color_hex"`
	ColorName      string    `json:"color_name"`
	SizeCode       string    `json:"size_code"`
	Stock          int       `json:"stock"`
	Sku            string    `json:"sku"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type AdminVariantListResponse struct {
	Items []AdminVariantResponse `json:"items"`
}

type UpdateVariantStockRequest struct {
	Stock int `json:"stock" validate:"min=0"`
}

type UpdateVariantRequest struct {
	Sku string `json:"sku" validate:"omitempty"`
}

