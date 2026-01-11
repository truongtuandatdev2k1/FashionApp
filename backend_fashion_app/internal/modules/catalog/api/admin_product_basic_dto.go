package api

type AdminUpdateProductBasicRequest struct {
	Name        string  `json:"name" validate:"required"`
	Price       float64 `json:"price" validate:"min=0"`
	DiscountPct int     `json:"discount_pct" validate:"min=0,max=100"`
	BrandID     *uint   `json:"brand_id"`
	CategoryIDs []uint  `json:"category_ids"`
	StyleIDs    []uint  `json:"style_ids"`
	IsHotTrend  bool    `json:"is_hot_trend"`
	AgeRange    string  `json:"age_range"`
	Description string  `json:"description"`
}
