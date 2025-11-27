package services

import (
	"context"
	"fmt"
	"myfashion/internal/modules/promotion/api"
	"myfashion/internal/modules/promotion/entities"
	"time"
)

// PromotionService chứa logic nghiệp vụ cho module Promotion
type PromotionService struct {
	promoRepo PromotionRepository
	userRepo  UserRepository
	orderRepo OrderRepository
}

// NewPromotionService tạo một service mới
func NewPromotionService(promoRepo PromotionRepository, userRepo UserRepository, orderRepo OrderRepository) *PromotionService {
	return &PromotionService{
		promoRepo: promoRepo,
		userRepo:  userRepo,
		orderRepo: orderRepo,
	}
}

// CreatePromotion xử lý việc tạo một khuyến mãi mới (cho Admin)
func (s *PromotionService) CreatePromotion(ctx context.Context, req *api.CreatePromotionRequest) (*entities.Promotion, error) {
	// Kiểm tra xem mã đã tồn tại chưa
	existing, _ := s.promoRepo.FindByCode(ctx, req.Code)
	if existing != nil {
		return nil, entities.ErrPromotionCodeExists
	}

	promotion := req.ToEntity()

	if err := s.promoRepo.Create(ctx, promotion); err != nil {
		return nil, err
	}

	return promotion, nil
}

// ValidatePromotions xử lý việc kiểm tra và áp dụng một hoặc nhiều mã khuyến mãi
func (s *PromotionService) ValidatePromotions(ctx context.Context, userID uint, req *api.ValidatePromotionRequest) (*api.ValidatePromotionResponse, error) {
	response := &api.ValidatePromotionResponse{
		AppliedPromotions: []api.AppliedPromotion{},
		InvalidPromotions: []api.InvalidPromotion{},
	}

	promotions := []*entities.Promotion{}

	// 1. Lấy thông tin tất cả các mã
	for _, code := range req.Codes {
		p, err := s.promoRepo.FindByCode(ctx, code)
		if err != nil {
			response.InvalidPromotions = append(response.InvalidPromotions, api.InvalidPromotion{Code: code, Reason: entities.ErrPromotionNotFound.Error()})
			continue
		}
		promotions = append(promotions, p)
	}

	// 2. Kiểm tra tính cộng dồn
	if len(promotions) > 1 {
		for _, p := range promotions {
			if !p.IsStackable {
				response.InvalidPromotions = append(response.InvalidPromotions, api.InvalidPromotion{Code: p.Code, Reason: entities.ErrPromotionNotStackable.Error()})
				// Nếu có 1 mã không thể cộng dồn, loại bỏ tất cả và báo lỗi
				// Hoặc có thể chỉ loại bỏ mã đó, tùy theo nghiệp vụ. Ở đây ta loại bỏ tất cả.
				return response, nil
			}
		}
	}

	// 3. Lặp qua từng mã để xác thực
	for _, p := range promotions {
		if err := s.validateSinglePromotion(ctx, userID, p, req.OrderSubtotal); err != nil {
			response.InvalidPromotions = append(response.InvalidPromotions, api.InvalidPromotion{Code: p.Code, Reason: err.Error()})
			continue
		}
		response.AppliedPromotions = append(response.AppliedPromotions, api.AppliedPromotion{Code: p.Code, Type: string(p.Type)})
	}

	// 4. Tính toán tổng giảm giá
	s.calculateSummary(response, promotions, req)

	return response, nil
}

// validateSinglePromotion kiểm tra các điều kiện của một mã khuyến mãi
func (s *PromotionService) validateSinglePromotion(ctx context.Context, userID uint, p *entities.Promotion, orderSubtotal float64) error {
	// Check 1: Mã còn hoạt động?
	if !p.IsActive {
		return entities.ErrPromotionNotActive
	}
	now := time.Now()
	if now.Before(p.StartDate) || now.After(p.EndDate) {
		return entities.ErrPromotionExpired
	}

	// Check 2: Còn lượt sử dụng chung?
	if p.UsageLimit > 0 && p.UsageCount >= p.UsageLimit {
		return entities.ErrPromotionUsageLimitReached
	}

	// Check 3: User còn lượt sử dụng?
	// (Cần triển khai logic đếm số lần user đã dùng mã này)

	// Check 4: User có thuộc nhóm đối tượng?
	switch p.TargetGroup {
	case entities.TargetNewCustomers:
		hasOrders, err := s.userRepo.HasOrders(ctx, userID)
		if err != nil || hasOrders {
			return entities.ErrPromotionNotApplicableToUser
		}
	case entities.TargetSpecificUsers:
		found := false
		for _, id := range p.ApplicableUsers {
			if id == userID {
				found = true
				break
			}
		}
		if !found {
			return entities.ErrPromotionNotApplicableToUser
		}
	case entities.TargetCustomerTier:
		userTier, err := s.userRepo.GetUserTier(ctx, userID)
		if err != nil {
			return entities.ErrPromotionNotApplicableToUser
		}
		found := false
		for _, tier := range p.ApplicableTiers {
			if tier == userTier {
				found = true
				break
			}
		}
		if !found {
			return entities.ErrPromotionNotApplicableToUser
		}
	}

	// Check 5: Đơn hàng đủ điều kiện?
	if orderSubtotal < p.MinOrderValue {
		return fmt.Errorf("%w (yêu cầu tối thiểu %.0f)", entities.ErrPromotionMinOrderValueNotMet, p.MinOrderValue)
	}

	return nil
}

// calculateSummary tính toán tổng tiền sau khi đã có danh sách mã hợp lệ
// RecordUsage increases the usage count for a list of promotions.
func (s *PromotionService) RecordUsage(ctx context.Context, codes []string) error {
	for _, code := range codes {
		p, err := s.promoRepo.FindByCode(ctx, code)
		if err != nil {
			// Log or ignore error for promotions that might have been deleted in the meantime
			continue
		}
		if err := s.promoRepo.IncrementUsageCount(ctx, p.ID, 1); err != nil {
			// Log or handle error, but don't stop the loop
			continue
		}
	}
	return nil
}

func (s *PromotionService) calculateSummary(response *api.ValidatePromotionResponse, promotions []*entities.Promotion, req *api.ValidatePromotionRequest) {
	var totalOrderDiscount float64
	var totalShippingDiscount float64

	for i, applied := range response.AppliedPromotions {
		// Tìm lại promotion tương ứng
		var p *entities.Promotion
		for _, promo := range promotions {
			if promo.Code == applied.Code {
				p = promo
				break
			}
		}
		if p == nil {
			continue
		}

		var discount float64
		switch p.Type {
		case entities.TypeOrderPercentage:
			discount = req.OrderSubtotal * (p.Value / 100)
			if p.MaxDiscount != nil && discount > *p.MaxDiscount {
				discount = *p.MaxDiscount
			}
			totalOrderDiscount += discount
		case entities.TypeOrderFixed:
			discount = p.Value
			totalOrderDiscount += discount
		case entities.TypeShippingFixed:
			discount = p.Value
			if p.MaxDiscount != nil && discount > *p.MaxDiscount {
				discount = *p.MaxDiscount
			}
			totalShippingDiscount += discount
		case entities.TypeFreeShipping:
			discount = req.ShippingFee
			totalShippingDiscount += discount
		}
		response.AppliedPromotions[i].DiscountAmount = discount
	}

	// Hậu xử lý
	if totalOrderDiscount > req.OrderSubtotal {
		totalOrderDiscount = req.OrderSubtotal
	}
	if totalShippingDiscount > req.ShippingFee {
		totalShippingDiscount = req.ShippingFee
	}

	response.Summary = api.PromotionSummary{
		OrderSubtotal:         req.OrderSubtotal,
		TotalOrderDiscount:    totalOrderDiscount,
		TotalShippingDiscount: totalShippingDiscount,
		FinalAmount:           req.OrderSubtotal - totalOrderDiscount,
	}
}
