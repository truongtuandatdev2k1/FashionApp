package entities

import "time"

type ProductVariant struct {
	ID             uint         `gorm:"primaryKey"`
	ProductID      uint         `gorm:"not null"`
	Product        Product      `gorm:"foreignKey:ProductID"`
	ProductColorID uint         `gorm:"not null;index"`
	ProductColor   ProductColor `gorm:"foreignKey:ProductColorID"`
	SizeCode       string       `gorm:"column:size_code;type:varchar(10);not null"`
	Stock          int          `gorm:"not null"`
	Sku            string       `gorm:"type:varchar(100);unique;not null"`
	CreatedAt      time.Time    `gorm:"autoCreateTime"`
	UpdatedAt      time.Time    `gorm:"autoUpdateTime"`
}

func (ProductVariant) TableName() string {
	return "product_variants"
}
