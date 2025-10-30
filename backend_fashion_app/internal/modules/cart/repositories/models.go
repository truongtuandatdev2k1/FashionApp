package repositories

import "time"

// CartModel maps to the carts table
type CartModel struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"column:user_id;not null;uniqueIndex"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (CartModel) TableName() string {
	return "carts"
}

// CartItemModel maps to the cart_items table
type CartItemModel struct {
	ID            uint      `gorm:"primaryKey"`
	CartID        uint      `gorm:"column:cart_id;not null;index"`
	ProductID     uint      `gorm:"column:product_id;not null;index"`
	Quantity      int       `gorm:"column:quantity;not null;default:1"`
	PriceSnapshot float64   `gorm:"column:price_snapshot;type:decimal(10,2);not null"`
	CreatedAt     time.Time `gorm:"column:created_at"`
	UpdatedAt     time.Time `gorm:"column:updated_at"`
}

func (CartItemModel) TableName() string {
	return "cart_items"
}
