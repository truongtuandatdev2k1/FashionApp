package entities

import "time"

type Product struct {
	ID          uint           `gorm:"primaryKey"`
	CategoryIDs string         `gorm:"column:category_ids;type:varchar(255)"`
	StyleIDs    string         `gorm:"column:style_ids;type:varchar(255)"`
	Categories  []Category     `gorm:"-"` // Populated by service
	Styles      []Style        `gorm:"-"` // Populated by service
	Name        string         `gorm:"type:varchar(255);not null"`
	Price       float64        `gorm:"type:decimal(10,2);not null"`
	DiscountPct int            `gorm:"column:discount_pct;default:0"`
	PriceAfter  float64        `gorm:"type:decimal(10,2);not null"`
	Color       string         `gorm:"type:varchar(50)"`
	AgeRange    string         `gorm:"column:age_range;type:varchar(50)"`
	Description string         `gorm:"type:text"`
	ImageURL    string         `gorm:"column:image_url;type:varchar(255)"`
	Images      []ProductImage `gorm:"foreignKey:ProductID"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
