package repositories

import (
	"time"

	authRepositories "myfashion/internal/modules/auth/repositories"
	catalogRepositories "myfashion/internal/modules/catalog/repositories"
)

// CartModel maps to the carts table
type CartModel struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"column:user_id;not null;uniqueIndex"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt time.Time `gorm:"column:updated_at;autoUpdateTime"`

	User  authRepositories.UserModel `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Items []CartItemModel            `gorm:"foreignKey:CartID;constraint:OnDelete:CASCADE"`
}

func (CartModel) TableName() string {
	return "carts"
}

// CartItemModel maps to the cart_items table
type CartItemModel struct {
	ID               uint      `gorm:"primaryKey"`
	CartID           uint      `gorm:"column:cart_id;not null;index;uniqueIndex:ux_cart_variant,priority:1"`
	ProductVariantID uint      `gorm:"column:product_variant_id;not null;index;uniqueIndex:ux_cart_variant,priority:2"`
	Quantity         int       `gorm:"column:quantity;not null;default:1"`
	PriceSnapshot    float64   `gorm:"column:price_snapshot;type:decimal(10,2);not null"`
	CreatedAt        time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt        time.Time `gorm:"column:updated_at;autoUpdateTime"`

	Cart           CartModel                               `gorm:"foreignKey:CartID;constraint:OnDelete:CASCADE"`
	ProductVariant catalogRepositories.ProductVariantModel `gorm:"foreignKey:ProductVariantID;constraint:OnDelete:CASCADE"`
}

func (CartItemModel) TableName() string {
	return "cart_items"
}
