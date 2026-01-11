package repositories

import (
	"context"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PaymentRepository struct {
	db *gorm.DB
}

func NewPaymentRepository(db *gorm.DB) *PaymentRepository {
	return &PaymentRepository{db: db}
}

func (r *PaymentRepository) Create(ctx context.Context, m *PaymentModel) error {
	return r.db.WithContext(ctx).Create(m).Error
}

func (r *PaymentRepository) Update(ctx context.Context, m *PaymentModel) error {
	return r.db.WithContext(ctx).Save(m).Error
}

func (r *PaymentRepository) FindByOrderID(ctx context.Context, orderID uuid.UUID) (*PaymentModel, error) {
	var m PaymentModel
	if err := r.db.WithContext(ctx).Where("order_id = ?", orderID).First(&m).Error; err != nil {
		return nil, err
	}
	return &m, nil
}

func (r *PaymentRepository) FindByPayosOrderCode(ctx context.Context, orderCode uint64) (*PaymentModel, error) {
	var m PaymentModel
	if err := r.db.WithContext(ctx).Where("payos_order_code = ?", orderCode).First(&m).Error; err != nil {
		return nil, err
	}
	return &m, nil
}

