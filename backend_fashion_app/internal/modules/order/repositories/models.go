package repositories

import (
	"time"

	"github.com/google/uuid"
)

// OrderModel represents the order table
type OrderModel struct {
	ID          uuid.UUID `gorm:"type:char(36);primaryKey"`
	OrderNumber string    `gorm:"type:varchar(50);uniqueIndex;not null"`
	CustomerID  uint      `gorm:"not null;index"`
	ShopID      uint      `gorm:"not null;index"`

	// Shipping info
	ShippingName     string `gorm:"type:varchar(255);not null"`
	ShippingPhone    string `gorm:"type:varchar(20);not null"`
	ShippingAddress  string `gorm:"type:text;not null"`
	ShippingProvince string `gorm:"type:varchar(100)"`
	ShippingDistrict string `gorm:"type:varchar(100)"`
	ShippingWard     string `gorm:"type:varchar(100)"`

	// Order details
	TotalAmount    float64 `gorm:"type:decimal(15,2);not null;default:0"`
	ShippingFee    float64 `gorm:"type:decimal(15,2);not null;default:0"`
	DiscountAmount float64 `gorm:"type:decimal(15,2);not null;default:0"`
	FinalAmount    float64 `gorm:"type:decimal(15,2);not null;default:0"`

	// Payment
	PaymentMethod string `gorm:"type:varchar(50);not null"`
	PaymentStatus string `gorm:"type:varchar(50);not null"`

	// Status
	Status       string `gorm:"type:varchar(50);not null;index"`
	Note         string `gorm:"type:text"`
	CancelReason string `gorm:"type:text"`

	// Timestamps
	CreatedAt   time.Time `gorm:"not null"`
	UpdatedAt   time.Time `gorm:"not null"`
	ConfirmedAt *time.Time
	ShippedAt   *time.Time
	DeliveredAt *time.Time
	CancelledAt *time.Time

	// Relations
	Items []OrderItemModel `gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE"`
}

func (OrderModel) TableName() string {
	return "orders"
}

// OrderItemModel represents the order_items table
type OrderItemModel struct {
	ID           uuid.UUID `gorm:"type:char(36);primaryKey"`
	OrderID      uuid.UUID `gorm:"type:char(36);not null;index"`
	ProductID    uint      `gorm:"not null"`
	ProductName  string    `gorm:"type:varchar(255);not null"`
	ProductSKU   string    `gorm:"type:varchar(100)"`
	ProductImage string    `gorm:"type:text"`
	Size         string    `gorm:"type:varchar(50)"`
	Color        string    `gorm:"type:varchar(50)"`
	Quantity     int       `gorm:"not null"`
	Price        float64   `gorm:"type:decimal(15,2);not null"`
	Subtotal     float64   `gorm:"type:decimal(15,2);not null"`
	CreatedAt    time.Time `gorm:"not null"`
}

func (OrderItemModel) TableName() string {
	return "order_items"
}
