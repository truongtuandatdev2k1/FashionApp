package repositories

import (
	"context"
	"errors"

	"myfashion/internal/modules/order/entities"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderRepository struct {
	db *gorm.DB
}

func NewOrderRepository(db *gorm.DB) *OrderRepository {
	return &OrderRepository{db: db}
}

// Create creates a new order with items
func (r *OrderRepository) Create(ctx context.Context, order *entities.Order) error {
	model := toModel(order)

	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// Create order
		if err := tx.Create(model).Error; err != nil {
			return err
		}

		// Update entity with created data
		*order = *toEntity(model)
		return nil
	})
}

// FindByID finds an order by ID with items
func (r *OrderRepository) FindByID(ctx context.Context, id uuid.UUID) (*entities.Order, error) {
	var model OrderModel

	err := r.db.WithContext(ctx).
		Preload("Items").
		Where("id = ?", id).
		First(&model).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, entities.ErrOrderNotFound
		}
		return nil, err
	}

	return toEntity(&model), nil
}

// FindByOrderNumber finds an order by order number
func (r *OrderRepository) FindByOrderNumber(ctx context.Context, orderNumber string) (*entities.Order, error) {
	var model OrderModel

	err := r.db.WithContext(ctx).
		Preload("Items").
		Where("order_number = ?", orderNumber).
		First(&model).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, entities.ErrOrderNotFound
		}
		return nil, err
	}

	return toEntity(&model), nil
}

// FindByCustomerID finds all orders for a customer
func (r *OrderRepository) FindByCustomerID(ctx context.Context, customerID uint, limit, offset int) ([]*entities.Order, int64, error) {
	var models []OrderModel
	var total int64

	// Count total
	if err := r.db.WithContext(ctx).
		Model(&OrderModel{}).
		Where("customer_id = ?", customerID).
		Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get orders
	err := r.db.WithContext(ctx).
		Preload("Items").
		Where("customer_id = ?", customerID).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&models).Error

	if err != nil {
		return nil, 0, err
	}

	orders := make([]*entities.Order, len(models))
	for i, model := range models {
		orders[i] = toEntity(&model)
	}

	return orders, total, nil
}

// FindByShopID finds all orders for a shop
func (r *OrderRepository) FindByShopID(ctx context.Context, shopID uint, limit, offset int) ([]*entities.Order, int64, error) {
	var models []OrderModel
	var total int64

	// Count total
	if err := r.db.WithContext(ctx).
		Model(&OrderModel{}).
		Where("shop_id = ?", shopID).
		Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get orders
	err := r.db.WithContext(ctx).
		Preload("Items").
		Where("shop_id = ?", shopID).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&models).Error

	if err != nil {
		return nil, 0, err
	}

	orders := make([]*entities.Order, len(models))
	for i, model := range models {
		orders[i] = toEntity(&model)
	}

	return orders, total, nil
}

// FindByCustomerIDAndStatus finds orders by customer and status
func (r *OrderRepository) FindByCustomerIDAndStatus(ctx context.Context, customerID uint, status entities.OrderStatus, limit, offset int) ([]*entities.Order, int64, error) {
	var models []OrderModel
	var total int64

	// Count total
	if err := r.db.WithContext(ctx).
		Model(&OrderModel{}).
		Where("customer_id = ? AND status = ?", customerID, string(status)).
		Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get orders
	err := r.db.WithContext(ctx).
		Preload("Items").
		Where("customer_id = ? AND status = ?", customerID, string(status)).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&models).Error

	if err != nil {
		return nil, 0, err
	}

	orders := make([]*entities.Order, len(models))
	for i, model := range models {
		orders[i] = toEntity(&model)
	}

	return orders, total, nil
}

// Update updates an order
func (r *OrderRepository) Update(ctx context.Context, order *entities.Order) error {
	model := toModel(order)

	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// Update order (without items)
		if err := tx.Model(&OrderModel{}).
			Where("id = ?", model.ID).
			Updates(map[string]interface{}{
				"status":         model.Status,
				"payment_status": model.PaymentStatus,
				"cancel_reason":  model.CancelReason,
				"note":           model.Note,
				"updated_at":     model.UpdatedAt,
				"confirmed_at":   model.ConfirmedAt,
				"shipped_at":     model.ShippedAt,
				"delivered_at":   model.DeliveredAt,
				"cancelled_at":   model.CancelledAt,
			}).Error; err != nil {
			return err
		}

		return nil
	})
}

// Delete deletes an order (soft delete by marking as cancelled)
func (r *OrderRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).
		Where("id = ?", id).
		Delete(&OrderModel{}).Error
}
