package services

import (
	"context"
	"myfashion/internal/modules/promotion/entities"
)

// PromotionRepository định nghĩa interface cho lớp repository của Promotion
type PromotionRepository interface {
	Create(ctx context.Context, promotion *entities.Promotion) error
	FindByCode(ctx context.Context, code string) (*entities.Promotion, error)
	IncrementUsageCount(ctx context.Context, promotionID uint, count int) error
}

// UserRepository định nghĩa interface để lấy thông tin người dùng
type UserRepository interface {
	GetUserTier(ctx context.Context, userID uint) (string, error)
	HasOrders(ctx context.Context, userID uint) (bool, error)
}

// OrderRepository định nghĩa interface để tương tác với đơn hàng
type OrderRepository interface {
	RecordPromotionUsage(ctx context.Context, orderID string, promotionID uint, discountAmount float64) error
	CountByUserID(ctx context.Context, userID uint) (int64, error)
}
