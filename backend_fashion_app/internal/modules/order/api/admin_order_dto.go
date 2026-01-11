package api

import (
	"time"

	"myfashion/internal/modules/order/entities"

	"github.com/google/uuid"
)

type AdminOrderSummary struct {
	ID            uuid.UUID            `json:"id"`
	OrderNumber   string               `json:"order_number"`
	Status        entities.OrderStatus `json:"status"`
	PaymentStatus string               `json:"payment_status"`
	CustomerName  string               `json:"customer_name"`
	ShippingPhone string               `json:"shipping_phone"`
	TotalAmount   float64              `json:"total_amount"`
	CreatedAt     time.Time            `json:"created_at"`
}

type AdminOrderListResponse struct {
	Items  []AdminOrderSummary `json:"items"`
	Total  int64               `json:"total"`
	Limit  int                 `json:"limit"`
	Offset int                 `json:"offset"`
}
