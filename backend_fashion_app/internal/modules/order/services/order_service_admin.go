package services

import (
	"context"

	"github.com/google/uuid"
	"myfashion/internal/modules/order/entities"
)

func (s *OrderService) AdminListOrders(ctx context.Context, filter AdminOrderFilter, limit, offset int) ([]*entities.Order, int64, error) {
	return s.orderRepo.FindAdmin(ctx, filter, limit, offset)
}

func (s *OrderService) AdminGetOrderByID(ctx context.Context, orderID uuid.UUID) (*entities.Order, error) {
	return s.orderRepo.FindByID(ctx, orderID)
}

