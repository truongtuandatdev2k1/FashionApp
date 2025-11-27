package entities

import "time"

type ProductColor struct {
	ID        uint      `gorm:"primaryKey"`
	ProductID uint      `gorm:"not null;index"`
	ColorHex  string    `gorm:"type:varchar(7);not null"`  // e.g. #FF0000
	ColorName string    `gorm:"type:varchar(50);not null"` // e.g. "Đỏ"
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	// Relations
	Images   []ProductColorImage `gorm:"foreignKey:ProductColorID;constraint:OnDelete:CASCADE"`
	Variants []ProductVariant    `gorm:"foreignKey:ProductID"` // sẽ được điều chỉnh khi hoàn tất refactor variant
}

func (ProductColor) TableName() string { return "product_colors" }
