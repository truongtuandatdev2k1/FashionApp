package repositories

import "time"

// ProductViewModel maps to the product_views table
type ProductViewModel struct {
	UserID    uint      `gorm:"primaryKey;autoIncrement:false;index:idx_user_views,priority:1"`
	ProductID uint      `gorm:"primaryKey;autoIncrement:false"`
	ViewedAt  time.Time `gorm:"index:idx_user_views,priority:2"`
}

func (ProductViewModel) TableName() string {
	return "product_views"
}

