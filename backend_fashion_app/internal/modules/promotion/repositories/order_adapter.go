package repositories

import (
	"context"

	orderServices "myfashion/internal/modules/order/services"
	"myfashion/internal/modules/promotion/api"
	promoServices "myfashion/internal/modules/promotion/services"
)

// PromotionServiceAdapter adapts the PromotionService to the interface expected by the Order module.
type PromotionServiceAdapter struct {
	promoService *promoServices.PromotionService
}

// NewPromotionServiceAdapter creates a new adapter.
func NewPromotionServiceAdapter(promoService *promoServices.PromotionService) *PromotionServiceAdapter {
	return &PromotionServiceAdapter{promoService: promoService}
}

// ValidatePromotions calls the underlying PromotionService's ValidatePromotions method.
func (a *PromotionServiceAdapter) ValidatePromotions(ctx context.Context, userID uint, input orderServices.PromotionValidationInput) (*orderServices.PromotionValidationOutput, error) {
	promoResult, err := a.promoService.ValidatePromotions(ctx, userID, &api.ValidatePromotionRequest{
		Codes:         input.Codes,
		OrderSubtotal: input.OrderSubtotal,
		ShippingFee:   input.ShippingFee,
	})
	if err != nil {
		return nil, err
	}

	appliedPromos := make([]orderServices.AppliedPromotion, len(promoResult.AppliedPromotions))
	for i, p := range promoResult.AppliedPromotions {
		appliedPromos[i] = orderServices.AppliedPromotion{
			Code:           p.Code,
			DiscountAmount: p.DiscountAmount,
		}
	}

	return &orderServices.PromotionValidationOutput{
		TotalOrderDiscount:    promoResult.Summary.TotalOrderDiscount,
		TotalShippingDiscount: promoResult.Summary.TotalShippingDiscount,
		FinalAmount:           promoResult.Summary.FinalAmount,
		AppliedPromotions:     appliedPromos,
	}, nil
}

// RecordUsage calls the underlying PromotionService's RecordUsage method.
func (a *PromotionServiceAdapter) RecordUsage(ctx context.Context, codes []string) error {
	return a.promoService.RecordUsage(ctx, codes)
}
