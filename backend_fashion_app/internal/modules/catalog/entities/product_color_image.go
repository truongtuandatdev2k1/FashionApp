package entities

import "time"

type ProductColorImage struct {
	ID             uint      `gorm:"primaryKey"`
	ProductColorID uint      `gorm:"not null;index"`
	ImageURL       string    `gorm:"column:image_url;type:varchar(255);not null"`
	SortOrder      int       `gorm:"column:sort_order;default:0"`
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime"`
}

func (ProductColorImage) TableName() string { return "product_color_images" }
