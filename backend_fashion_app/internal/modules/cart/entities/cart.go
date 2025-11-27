package entities

import "time"

// Cart đại diện cho giỏ hàng của một người dùng
type Cart struct {
	ID        uint       `gorm:"primaryKey"`
	UserID    uint       `gorm:"not null;uniqueIndex"` // Mỗi user chỉ có 1 giỏ hàng
	Items     []CartItem `gorm:"foreignKey:CartID;constraint:OnDelete:CASCADE"`
	CreatedAt time.Time  `gorm:"autoCreateTime"`
	UpdatedAt time.Time  `gorm:"autoUpdateTime"`
}

func (Cart) TableName() string {
	return "carts"
}
