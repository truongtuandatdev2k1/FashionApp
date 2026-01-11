package repositories

import (
	"context"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderAdapter struct {
	db *gorm.DB
}

func NewOrderAdapter(db *gorm.DB) *OrderAdapter {
	return &OrderAdapter{db: db}
}

type OrderModel struct {
	ID            uuid.UUID `gorm:"type:char(36);primaryKey"`
	OrderNumber   string
	OrderCode     uint64
	CustomerID    uint
	FinalAmount   float64
	PaymentStatus string
	Status        string
	ConfirmedAt   *time.Time
	UpdatedAt     time.Time
}

func (OrderModel) TableName() string { return "orders" }

func (r *OrderAdapter) FindByID(ctx context.Context, id uuid.UUID) (*OrderModel, error) {
	var m OrderModel
	if err := r.db.WithContext(ctx).Where("id = ?", id).First(&m).Error; err != nil {
		return nil, err
	}
	return &m, nil
}

func (r *OrderAdapter) FindByOrderCode(ctx context.Context, orderCode uint64) (*OrderModel, error) {
	var m OrderModel
	if err := r.db.WithContext(ctx).Where("order_code = ?", orderCode).First(&m).Error; err != nil {
		return nil, err
	}
	return &m, nil
}

func (r *OrderAdapter) SetPaidAndConfirm(ctx context.Context, id uuid.UUID) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&OrderModel{}).
		Where("id = ?", id).
		Updates(map[string]any{
			"payment_status": "paid",
			"status":         "confirmed",
			"confirmed_at":   &now,
			"updated_at":     now,
		}).Error
}

