package entities

import (
	"time"

	"github.com/google/uuid"
)

// OrderStatus represents the status of an order
type OrderStatus string

const (
	OrderStatusPending    OrderStatus = "pending"    // Đơn hàng mới tạo
	OrderStatusConfirmed  OrderStatus = "confirmed"  // Shop đã xác nhận
	OrderStatusProcessing OrderStatus = "processing" // Đang chuẩn bị hàng
	OrderStatusShipping   OrderStatus = "shipping"   // Đang giao hàng
	OrderStatusDelivered  OrderStatus = "delivered"  // Đã giao hàng
	OrderStatusCancelled  OrderStatus = "cancelled"  // Đã hủy
	OrderStatusReturned   OrderStatus = "returned"   // Đã trả hàng
)

// PaymentMethod represents payment method
type PaymentMethod string

const (
	PaymentMethodCOD          PaymentMethod = "cod"           // Cash on delivery
	PaymentMethodBankTransfer PaymentMethod = "bank_transfer" // Chuyển khoản
	PaymentMethodEWallet      PaymentMethod = "e_wallet"      // Ví điện tử
)

// PaymentStatus represents payment status
type PaymentStatus string

const (
	PaymentStatusPending  PaymentStatus = "pending"
	PaymentStatusPaid     PaymentStatus = "paid"
	PaymentStatusFailed   PaymentStatus = "failed"
	PaymentStatusRefunded PaymentStatus = "refunded"
)

// Order represents a customer order
type Order struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey"`
	OrderNumber string    `gorm:"type:varchar(50);unique;not null"` // Mã đơn hàng (unique)
	OrderCode   uint64    `gorm:"unique;not null"`                  // Mã đơn dạng số (phục vụ PayOS)
	CustomerID  uint      `gorm:"not null;index"`
	ShopID      uint      `gorm:"not null;index"`

	// Shipping info
	ShippingName     string `gorm:"type:varchar(255)"`
	ShippingPhone    string `gorm:"type:varchar(20)"`
	ShippingAddress  string `gorm:"type:text"`
	ShippingProvince string `gorm:"type:varchar(100)"`
	ShippingDistrict string `gorm:"type:varchar(100)"`
	ShippingWard     string `gorm:"type:varchar(100)"`

	// Order details
	Items          []OrderItem `gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE"`
	TotalAmount    float64     `gorm:"type:decimal(10,2)"`
	ShippingFee    float64     `gorm:"type:decimal(10,2)"`
	DiscountAmount float64     `gorm:"type:decimal(10,2)"`
	FinalAmount    float64     `gorm:"type:decimal(10,2)"`

	// Payment
	PaymentMethod PaymentMethod `gorm:"type:varchar(20)"`
	PaymentStatus PaymentStatus `gorm:"type:varchar(20)"`

	// Status
	Status       OrderStatus `gorm:"type:varchar(20)"`
	Note         string      `gorm:"type:text"`
	CancelReason string      `gorm:"type:text"`

	// Timestamps
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
	ConfirmedAt *time.Time
	ShippedAt   *time.Time
	DeliveredAt *time.Time
	CancelledAt *time.Time
}

func (Order) TableName() string {
	return "orders"
}

// OrderItem represents an item in an order
type OrderItem struct {
	ID               uuid.UUID `gorm:"type:uuid;primaryKey"`
	OrderID          uuid.UUID `gorm:"type:uuid;not null;index"`
	ProductID        uint      `gorm:"not null;index"`
	ProductVariantID uint      `gorm:"not null;index"`
	ProductName      string    `gorm:"type:varchar(255)"`
	ProductSKU       string    `gorm:"type:varchar(100)"`
	ProductImage     string    `gorm:"type:varchar(255)"`
	Size             string    `gorm:"type:varchar(20)"`
	Color            string    `gorm:"type:varchar(50)"`
	Quantity         int       `gorm:"not null"`
	Price            float64   `gorm:"type:decimal(10,2)"` // Giá tại thời điểm đặt hàng
	Subtotal         float64   `gorm:"type:decimal(10,2)"` // Price * Quantity
	CreatedAt        time.Time `gorm:"autoCreateTime"`
}

func (OrderItem) TableName() string {
	return "order_items"
}

// NewOrder creates a new order
func NewOrder(customerID, shopID uint) *Order {
	return &Order{
		ID:            uuid.New(),
		OrderNumber:   generateOrderNumber(),
		OrderCode:     generateOrderCodeNumeric(),
		CustomerID:    customerID,
		ShopID:        shopID,
		Status:        OrderStatusPending,
		PaymentStatus: PaymentStatusPending,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
}

// generateOrderCodeNumeric generates a unique numeric code for payment providers (e.g., PayOS)
func generateOrderCodeNumeric() uint64 {
	// Simple implementation: timestamp in nanoseconds
	return uint64(time.Now().UnixNano())
}

// generateOrderNumber generates a unique order number
func generateOrderNumber() string {
	// Format: ORD-YYYYMMDD-XXXXXX (X là random)
	now := time.Now()
	return now.Format("ORD-20060102-") + uuid.New().String()[:6]
}

// CalculateTotals calculates order totals
func (o *Order) CalculateTotals() {
	o.TotalAmount = 0
	for _, item := range o.Items {
		o.TotalAmount += item.Subtotal
	}
	o.FinalAmount = o.TotalAmount + o.ShippingFee - o.DiscountAmount
}

// CanCancel checks if order can be cancelled
func (o *Order) CanCancel() bool {
	return o.Status == OrderStatusPending || o.Status == OrderStatusConfirmed
}

// CanConfirm checks if order can be confirmed
func (o *Order) CanConfirm() bool {
	return o.Status == OrderStatusPending
}

// CanUpdateStatus checks if order status can be updated
func (o *Order) CanUpdateStatus(newStatus OrderStatus) bool {
	switch o.Status {
	case OrderStatusPending:
		return newStatus == OrderStatusConfirmed || newStatus == OrderStatusCancelled
	case OrderStatusConfirmed:
		return newStatus == OrderStatusProcessing || newStatus == OrderStatusCancelled
	case OrderStatusProcessing:
		return newStatus == OrderStatusShipping || newStatus == OrderStatusCancelled
	case OrderStatusShipping:
		return newStatus == OrderStatusDelivered || newStatus == OrderStatusReturned
	default:
		return false
	}
}

// Confirm confirms the order
func (o *Order) Confirm() error {
	if !o.CanConfirm() {
		return ErrOrderCannotBeConfirmed
	}
	now := time.Now()
	o.Status = OrderStatusConfirmed
	o.ConfirmedAt = &now
	o.UpdatedAt = now
	return nil
}

// Cancel cancels the order
func (o *Order) Cancel(reason string) error {
	if !o.CanCancel() {
		return ErrOrderCannotBeCancelled
	}
	now := time.Now()
	o.Status = OrderStatusCancelled
	o.CancelReason = reason
	o.CancelledAt = &now
	o.UpdatedAt = now
	return nil
}

// UpdateStatus updates order status
func (o *Order) UpdateStatus(newStatus OrderStatus) error {
	if !o.CanUpdateStatus(newStatus) {
		return ErrInvalidStatusTransition
	}

	now := time.Now()
	o.Status = newStatus
	o.UpdatedAt = now

	switch newStatus {
	case OrderStatusShipping:
		o.ShippedAt = &now
	case OrderStatusDelivered:
		o.DeliveredAt = &now
		o.PaymentStatus = PaymentStatusPaid
	case OrderStatusCancelled:
		o.CancelledAt = &now
	}

	return nil
}
