package api

import (
	"myfashion/internal/modules/promotion/entities"
	"time"
)

// ========== ADMIN DTOs ==========

// CreatePromotionRequest định nghĩa request body để tạo một khuyến mãi mới
type CreatePromotionRequest struct {
	Code            string    `json:"code" validate:"required" example:"SALE50"`
	Name            string    `json:"name" validate:"required" example:"Giảm 50k cho đơn hàng trên 500k"`
	Description     string    `json:"description" example:"Áp dụng cho tất cả sản phẩm, trừ hàng mới về."`
	Type            string    `json:"type" validate:"required,oneof=order_fixed order_percentage shipping_fixed free_shipping" example:"order_fixed, order_percentage, shipping_fixed, free_shipping"`
	Value           float64   `json:"value" validate:"required,gt=0" example:"50000"`
	MaxDiscount     *float64  `json:"max_discount,omitempty" example:"100000"`
	MinOrderValue   float64   `json:"min_order_value" validate:"gte=0" example:"500000"`
	StartDate       time.Time `json:"start_date" validate:"required" example:"2025-11-01T00:00:00Z"`
	EndDate         time.Time `json:"end_date" validate:"required,gtfield=StartDate" example:"2025-11-30T23:59:59Z"`
	UsageLimit      int       `json:"usage_limit" validate:"gte=0" example:"1000"`
	UserUsageLimit  int       `json:"user_usage_limit" validate:"gte=0" example:"1"`
	IsActive        *bool     `json:"is_active" example:"true"`
	IsStackable     bool      `json:"is_stackable" example:"false"`
	TargetGroup     string    `json:"target_group" validate:"required,oneof=all new_customer specific_users customer_tier" example:"all, new_customer, specific_users, customer_tier"`
	ApplicableTiers []string  `json:"applicable_tiers,omitempty" example:"gold,silver"`
	ApplicableUsers []uint    `json:"applicable_users,omitempty" example:"101,102"`
}

// PromotionResponse định nghĩa response trả về cho một khuyến mãi
type PromotionResponse struct {
	ID              uint      `json:"id"`
	Code            string    `json:"code"`
	Name            string    `json:"name"`
	Description     string    `json:"description"`
	Type            string    `json:"type"`
	Value           float64   `json:"value"`
	MaxDiscount     *float64  `json:"max_discount,omitempty"`
	MinOrderValue   float64   `json:"min_order_value"`
	StartDate       time.Time `json:"start_date"`
	EndDate         time.Time `json:"end_date"`
	UsageLimit      int       `json:"usage_limit"`
	UsageCount      int       `json:"usage_count"`
	UserUsageLimit  int       `json:"user_usage_limit"`
	IsActive        bool      `json:"is_active"`
	IsStackable     bool      `json:"is_stackable"`
	TargetGroup     string    `json:"target_group"`
	ApplicableTiers []string  `json:"applicable_tiers,omitempty"`
	ApplicableUsers []uint    `json:"applicable_users,omitempty"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

// ========== CUSTOMER DTOs ==========

// ValidatePromotionRequest định nghĩa request body để kiểm tra mã khuyến mãi
type ValidatePromotionRequest struct {
	Codes         []string `json:"codes" validate:"required,min=1" example:"SALE50,FREESHIP"`
	OrderSubtotal float64  `json:"order_subtotal" validate:"gte=0" example:"600000"`
	ShippingFee   float64  `json:"shipping_fee" validate:"gte=0" example:"30000"`
}

// ValidatePromotionResponse định nghĩa response trả về sau khi kiểm tra mã
type ValidatePromotionResponse struct {
	AppliedPromotions []AppliedPromotion `json:"applied_promotions"`
	InvalidPromotions []InvalidPromotion `json:"invalid_promotions"`
	Summary           PromotionSummary   `json:"summary"`
}

// AppliedPromotion chứa thông tin về một mã đã áp dụng thành công
type AppliedPromotion struct {
	Code           string  `json:"code"`
	Type           string  `json:"type"`
	DiscountAmount float64 `json:"discount_amount"`
}

// InvalidPromotion chứa thông tin về một mã không hợp lệ
type InvalidPromotion struct {
	Code   string `json:"code"`
	Reason string `json:"reason"`
}

// PromotionSummary chứa tóm tắt tài chính sau khi áp dụng mã
type PromotionSummary struct {
	OrderSubtotal         float64 `json:"order_subtotal"`
	TotalOrderDiscount    float64 `json:"total_order_discount"`
	TotalShippingDiscount float64 `json:"total_shipping_discount"`
	FinalAmount           float64 `json:"final_amount"`
}

// ========== MAPPERS ==========

// ToEntity chuyển đổi từ CreatePromotionRequest DTO sang Promotion entity
func (req *CreatePromotionRequest) ToEntity() *entities.Promotion {
	isActive := true // Mặc định là active khi tạo mới
	if req.IsActive != nil {
		isActive = *req.IsActive
	}

	return &entities.Promotion{
		Code:            req.Code,
		Name:            req.Name,
		Description:     req.Description,
		Type:            entities.PromotionType(req.Type),
		Value:           req.Value,
		MaxDiscount:     req.MaxDiscount,
		MinOrderValue:   req.MinOrderValue,
		StartDate:       req.StartDate,
		EndDate:         req.EndDate,
		UsageLimit:      req.UsageLimit,
		UserUsageLimit:  req.UserUsageLimit,
		IsActive:        isActive,
		IsStackable:     req.IsStackable,
		TargetGroup:     entities.TargetGroup(req.TargetGroup),
		ApplicableTiers: req.ApplicableTiers,
		ApplicableUsers: req.ApplicableUsers,
	}
}

// ToResponse chuyển đổi từ Promotion entity sang PromotionResponse DTO
func ToResponse(p *entities.Promotion) *PromotionResponse {
	return &PromotionResponse{
		ID:              p.ID,
		Code:            p.Code,
		Name:            p.Name,
		Description:     p.Description,
		Type:            string(p.Type),
		Value:           p.Value,
		MaxDiscount:     p.MaxDiscount,
		MinOrderValue:   p.MinOrderValue,
		StartDate:       p.StartDate,
		EndDate:         p.EndDate,
		UsageLimit:      p.UsageLimit,
		UsageCount:      p.UsageCount,
		UserUsageLimit:  p.UserUsageLimit,
		IsActive:        p.IsActive,
		IsStackable:     p.IsStackable,
		TargetGroup:     string(p.TargetGroup),
		ApplicableTiers: p.ApplicableTiers,
		ApplicableUsers: p.ApplicableUsers,
		CreatedAt:       p.CreatedAt,
		UpdatedAt:       p.UpdatedAt,
	}
}
