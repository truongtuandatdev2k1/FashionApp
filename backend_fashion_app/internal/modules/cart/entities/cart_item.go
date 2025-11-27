package entities

import (
	"myfashion/internal/modules/catalog/entities"
	"time"
)

// CartItem đại diện cho một sản phẩm trong giỏ hàng
type CartItem struct {
	ID               uint                    `gorm:"primaryKey"`
	CartID           uint                    `gorm:"not null;index"`
	ProductVariantID uint                    `gorm:"not null;index"`
	ProductVariant   entities.ProductVariant `gorm:"foreignKey:ProductVariantID"`
	Quantity         int                     `gorm:"not null;default:1"`
	PriceSnapshot    float64                 `gorm:"type:decimal(10,2);not null"` // Giá tại thời điểm thêm vào giỏ
	CreatedAt        time.Time               `gorm:"autoCreateTime"`
	UpdatedAt        time.Time               `gorm:"autoUpdateTime"`
}

func (CartItem) TableName() string {
	return "cart_items"
}
