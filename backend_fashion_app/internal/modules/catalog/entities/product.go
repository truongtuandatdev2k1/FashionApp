package entities

import "time"

type Product struct {
	ID          uint      `gorm:"primaryKey"`
	Name        string    `gorm:"type:varchar(255);not null"`
	Price       float64   `gorm:"type:decimal(10,2);not null;default:0"`
	DiscountPct int       `gorm:"column:discount_pct;default:0"`
	PriceAfter  float64   `gorm:"column:price_after;type:decimal(10,2);not null;default:0"`
	AgeRange    string    `gorm:"column:age_range;type:varchar(50)"`
	Description string    `gorm:"type:text"`
	ImageURL    string    `gorm:"column:image_url;type:varchar(255)"`
	IsHotTrend  bool      `gorm:"column:is_hot_trend;default:false"`
	Status      string    `gorm:"type:varchar(20);default:'ACTIVE'"`
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`

	// Foreign keys and relationships
	BrandID *uint
	Brand   *Brand `gorm:"foreignKey:BrandID"`

	// Relationships
	Variants []ProductVariant `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE"`

	// Many-to-many relationships
	Categories []Category `gorm:"many2many:product_categories;"`
	Styles     []Style    `gorm:"many2many:product_styles;"`
}

func (Product) TableName() string {
	return "products"
}
