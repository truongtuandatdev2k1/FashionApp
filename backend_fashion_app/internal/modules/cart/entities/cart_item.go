package entities

import (
	"time"
)

// CartItem đại diện cho một sản phẩm trong giỏ hàng
type CartItem struct {
	ID            uint    `gorm:"primaryKey"`
	CartID        uint    `gorm:"not null;index"`
	ProductID     uint    `gorm:"not null;index"`
	Quantity      int     `gorm:"not null;default:1"`
	PriceSnapshot float64 `gorm:"type:decimal(10,2);not null"` // Giá tại thời điểm thêm vào giỏ
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

func (CartItem) TableName() string {
	return "cart_items"
}
