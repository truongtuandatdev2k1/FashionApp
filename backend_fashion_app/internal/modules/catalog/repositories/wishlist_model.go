package repositories

import "time"

type WishlistItemModel struct {
	UserID    uint      `gorm:"primaryKey;autoIncrement:false"`
	ProductID uint      `gorm:"primaryKey;autoIncrement:false"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

func (WishlistItemModel) TableName() string {
	return "wishlist_items"
}

