package repositories

import (
	"context"
	"time"

	"myfashion/internal/modules/order/entities"
	"myfashion/internal/modules/order/services"
)

func (r *OrderRepository) FindAdmin(ctx context.Context, filter services.AdminOrderFilter, limit, offset int) ([]*entities.Order, int64, error) {
	q := r.db.WithContext(ctx).Model(&OrderModel{}).
		Preload("Items").
		Preload("Customer").
		Order("created_at DESC")

	if filter.Status != nil {
		q = q.Where("status = ?", string(*filter.Status))
	}
	if filter.CustomerID != nil {
		q = q.Where("customer_id = ?", *filter.CustomerID)
	}
	if filter.FromDate != nil {
		q = q.Where("created_at >= ?", filter.FromDate.Format(time.RFC3339))
	}
	if filter.ToDate != nil {
		q = q.Where("created_at <= ?", filter.ToDate.Format(time.RFC3339))
	}

	var total int64
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	var models []OrderModel
	if err := q.Limit(limit).Offset(offset).Find(&models).Error; err != nil {
		return nil, 0, err
	}

	out := make([]*entities.Order, len(models))
	for i := range models {
		out[i] = toEntity(&models[i])
	}
	return out, total, nil
}
