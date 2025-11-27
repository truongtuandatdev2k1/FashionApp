package repositories

import (
	"context"

	orderEntities "myfashion/internal/modules/order/entities"
	orderRepos "myfashion/internal/modules/order/repositories"

	"gorm.io/gorm"
)

// --- Order Repository Adapter ---

type orderRepoAdapter struct {
	orderRepo *orderRepos.OrderRepository
}

func NewOrderRepoAdapter(db *gorm.DB) *orderRepoAdapter {
	return &orderRepoAdapter{
		orderRepo: orderRepos.NewOrderRepository(db),
	}
}

func (a *orderRepoAdapter) HasCompletedOrders(ctx context.Context, customerID uint) (bool, error) {
	// Lấy danh sách đơn hàng đã hoàn thành (delivered)
	orders, _, err := a.orderRepo.FindByCustomerIDAndStatus(ctx, customerID, orderEntities.OrderStatusDelivered, 1, 0)
	if err != nil {
		return false, err
	}
	return len(orders) > 0, nil
}

// CountByUserID is required to implement the services.OrderRepository interface.
// This method is not actively used by the current promotion logic, so it returns a default value.
// If future promotion logic requires counting all orders, this method should be fully implemented.
func (a *orderRepoAdapter) CountByUserID(ctx context.Context, userID uint) (int64, error) {
	// For now, this method is a placeholder to satisfy the interface.
	// We can implement the full logic if needed later.
	return 0, nil
}

// RecordPromotionUsage is required to implement the services.OrderRepository interface.
// This is a placeholder as the logic is handled within the promotion module itself.
func (a *orderRepoAdapter) RecordPromotionUsage(ctx context.Context, orderID string, promotionID uint, discountAmount float64) error {
	// This logic is currently managed by the promotion service's RecordUsage method.
	// This implementation is a placeholder to satisfy the interface.
	return nil
}

// --- User Repository Adapter ---

// Hiện tại, chúng ta chưa có logic về "tier" của khách hàng.
// Adapter này sẽ tạm thời trả về giá trị mặc định.
// Khi có logic về tier, chúng ta sẽ cập nhật ở đây.
type userRepoAdapter struct {
	// db *gorm.DB // Sẽ cần khi có logic tier
	orderRepo *orderRepos.OrderRepository // Dùng để kiểm tra khách hàng mới
}

func NewUserRepoAdapter(db *gorm.DB) *userRepoAdapter {
	return &userRepoAdapter{
		orderRepo: orderRepos.NewOrderRepository(db),
	}
}

// HasOrders kiểm tra xem khách hàng đã có đơn hàng nào chưa
func (a *userRepoAdapter) HasOrders(ctx context.Context, userID uint) (bool, error) {
	// Chỉ cần tìm 1 đơn hàng là đủ để xác định không phải khách hàng mới
	orders, _, err := a.orderRepo.FindByCustomerID(ctx, userID, 1, 0)
	if err != nil {
		return false, err
	}
	return len(orders) > 0, nil
}

// GetUserTier trả về hạng của khách hàng (tạm thời hardcode)
func (a *userRepoAdapter) GetUserTier(ctx context.Context, userID uint) (string, error) {
	// TODO: Implement user tier logic
	return "standard", nil
}
