package entities

import "time"

type ProductImage struct {
	ID        uint   `gorm:"primaryKey"`
	ProductID uint   `gorm:"column:product_id"`
	URL       string `gorm:"type:varchar(255);not null"`
	CreatedAt time.Time
}
