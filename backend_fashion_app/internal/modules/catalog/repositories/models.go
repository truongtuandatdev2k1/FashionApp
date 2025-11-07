package repositories

import "time"

// CategoryModel maps to the categories table
type CategoryModel struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"column:name;type:varchar(255);not null;unique"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (CategoryModel) TableName() string {
	return "categories"
}

// StyleModel maps to the styles table
type StyleModel struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"column:name;type:varchar(255);not null;unique"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (StyleModel) TableName() string {
	return "styles"
}

// ProductModel maps to the products table
type ProductModel struct {
	ID          uint      `gorm:"primaryKey"`
	CategoryIDs string    `gorm:"column:category_ids;type:varchar(255)"`
	StyleIDs    string    `gorm:"column:style_ids;type:varchar(255)"`
	Name        string    `gorm:"column:name;type:varchar(255);not null"`
	Price       float64   `gorm:"column:price;type:decimal(10,2);not null"`
	DiscountPct int       `gorm:"column:discount_pct;default:0"`
	PriceAfter  float64   `gorm:"column:price_after;type:decimal(10,2);not null"`
	Stock       int       `gorm:"column:stock;default:0;not null"`
	Color       string    `gorm:"column:color;type:varchar(50)"`
	AgeRange    string    `gorm:"column:age_range;type:varchar(50)"`
	Description string    `gorm:"column:description;type:text"`
	ImageURL    string    `gorm:"column:image_url;type:varchar(255)"`
	IsHotTrend  bool      `gorm:"column:is_hot_trend;default:false"`
	CreatedAt   time.Time `gorm:"column:created_at"`
	UpdatedAt   time.Time `gorm:"column:updated_at"`
}

func (ProductModel) TableName() string {
	return "products"
}

// ProductImageModel maps to the product_images table
type ProductImageModel struct {
	ID        uint      `gorm:"primaryKey"`
	ProductID uint      `gorm:"column:product_id"`
	URL       string    `gorm:"column:url;type:varchar(255);not null"`
	CreatedAt time.Time `gorm:"column:created_at"`
}

func (ProductImageModel) TableName() string {
	return "product_images"
}
