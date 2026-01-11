package api

type WishlistItemRequest struct {
	ProductID uint `json:"product_id"`
}

type WishlistListResponse struct {
	Items []ProductSummaryResponse `json:"items"`
}

