package api

import (
	"time"

	"myfashion/internal/modules/order/entities"

	"github.com/google/uuid"
)

// CreateOrderRequest represents the request to create an order
// @Description Request body for creating a new order from cart items
type CreateOrderRequest struct {
	AddressID     uint   `json:"address_id" validate:"required" example:"1"`
	CartItemIDs   []uint `json:"cart_item_ids" validate:"required,min=1" example:"1,2,3"`
	PaymentMethod string `json:"payment_method" validate:"required,oneof=cod bank_transfer e_wallet" example:"cod"`
	Note          string `json:"note" example:"Giao hàng giờ hành chính"`
} // @name CreateOrderRequest

// UpdateOrderStatusRequest represents the request to update order status
type UpdateOrderStatusRequest struct {
	Status string `json:"status" validate:"required,oneof=confirmed processing shipping delivered cancelled returned" example:"confirmed"`
} // @name UpdateOrderStatusRequest

// CancelOrderRequest represents the request to cancel an order
type CancelOrderRequest struct {
	Reason string `json:"reason" validate:"required" example:"Đặt nhầm sản phẩm"`
} // @name CancelOrderRequest

// OrderResponse represents an order response
type OrderResponse struct {
	ID               uuid.UUID           `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
	OrderNumber      string              `json:"order_number" example:"ORD-20240121-abc123"`
	CustomerID       uint                `json:"customer_id" example:"1"`
	ShopID           uint                `json:"shop_id" example:"2"`
	ShippingName     string              `json:"shipping_name" example:"Nguyễn Văn A"`
	ShippingPhone    string              `json:"shipping_phone" example:"0901234567"`
	ShippingAddress  string              `json:"shipping_address" example:"123 Đường ABC"`
	ShippingProvince string              `json:"shipping_province" example:"Hồ Chí Minh"`
	ShippingDistrict string              `json:"shipping_district" example:"Quận 1"`
	ShippingWard     string              `json:"shipping_ward" example:"Phường Bến Nghé"`
	Items            []OrderItemResponse `json:"items"`
	TotalAmount      float64             `json:"total_amount" example:"500000"`
	ShippingFee      float64             `json:"shipping_fee" example:"30000"`
	DiscountAmount   float64             `json:"discount_amount" example:"50000"`
	FinalAmount      float64             `json:"final_amount" example:"480000"`
	PaymentMethod    string              `json:"payment_method" example:"cod"`
	PaymentStatus    string              `json:"payment_status" example:"pending"`
	Status           string              `json:"status" example:"pending"`
	Note             string              `json:"note" example:"Giao hàng giờ hành chính"`
	CancelReason     string              `json:"cancel_reason,omitempty" example:""`
	CreatedAt        time.Time           `json:"created_at" example:"2024-01-21T10:00:00Z"`
	UpdatedAt        time.Time           `json:"updated_at" example:"2024-01-21T10:00:00Z"`
	ConfirmedAt      *time.Time          `json:"confirmed_at,omitempty" example:"2024-01-21T10:30:00Z"`
	ShippedAt        *time.Time          `json:"shipped_at,omitempty" example:"2024-01-21T14:00:00Z"`
	DeliveredAt      *time.Time          `json:"delivered_at,omitempty" example:"2024-01-22T10:00:00Z"`
	CancelledAt      *time.Time          `json:"cancelled_at,omitempty" example:""`
} // @name OrderResponse

// OrderItemResponse represents an order item response
type OrderItemResponse struct {
	ID           uuid.UUID `json:"id" example:"550e8400-e29b-41d4-a716-446655440003"`
	ProductID    uint      `json:"product_id" example:"1"`
	ProductName  string    `json:"product_name" example:"Áo thun nam basic"`
	ProductImage string    `json:"product_image" example:"https://example.com/image.jpg"`
	Quantity     int       `json:"quantity" example:"2"`
	Price        float64   `json:"price" example:"150000"`
	Subtotal     float64   `json:"subtotal" example:"300000"`
} // @name OrderItemResponse

// OrderListResponse represents a list of orders with pagination
type OrderListResponse struct {
	Orders []OrderResponse `json:"orders"`
	Total  int64           `json:"total" example:"100"`
	Limit  int             `json:"limit" example:"20"`
	Offset int             `json:"offset" example:"0"`
} // @name OrderListResponse

// ToOrderResponse converts an order entity to response DTO
func ToOrderResponse(order *entities.Order) OrderResponse {
	items := make([]OrderItemResponse, len(order.Items))
	for i, item := range order.Items {
		items[i] = OrderItemResponse{
			ID:           item.ID,
			ProductID:    item.ProductID,
			ProductName:  item.ProductName,
			ProductImage: item.ProductImage,
			Quantity:     item.Quantity,
			Price:        item.Price,
			Subtotal:     item.Subtotal,
		}
	}

	return OrderResponse{
		ID:               order.ID,
		OrderNumber:      order.OrderNumber,
		CustomerID:       order.CustomerID,
		ShopID:           order.ShopID,
		ShippingName:     order.ShippingName,
		ShippingPhone:    order.ShippingPhone,
		ShippingAddress:  order.ShippingAddress,
		ShippingProvince: order.ShippingProvince,
		ShippingDistrict: order.ShippingDistrict,
		ShippingWard:     order.ShippingWard,
		Items:            items,
		TotalAmount:      order.TotalAmount,
		ShippingFee:      order.ShippingFee,
		DiscountAmount:   order.DiscountAmount,
		FinalAmount:      order.FinalAmount,
		PaymentMethod:    string(order.PaymentMethod),
		PaymentStatus:    string(order.PaymentStatus),
		Status:           string(order.Status),
		Note:             order.Note,
		CancelReason:     order.CancelReason,
		CreatedAt:        order.CreatedAt,
		UpdatedAt:        order.UpdatedAt,
		ConfirmedAt:      order.ConfirmedAt,
		ShippedAt:        order.ShippedAt,
		DeliveredAt:      order.DeliveredAt,
		CancelledAt:      order.CancelledAt,
	}
}

// ToOrderListResponse converts a list of orders to response DTO
func ToOrderListResponse(orders []*entities.Order, total int64, limit, offset int) OrderListResponse {
	orderResponses := make([]OrderResponse, len(orders))
	for i, order := range orders {
		orderResponses[i] = ToOrderResponse(order)
	}

	return OrderListResponse{
		Orders: orderResponses,
		Total:  total,
		Limit:  limit,
		Offset: offset,
	}
}
