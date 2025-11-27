package repositories

import "time"

// CategoryModel maps to the categories table
type CategoryModel struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"column:name;type:varchar(255);not null;unique"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt time.Time `gorm:"column:updated_at;autoUpdateTime"`

	Products []ProductModel `gorm:"many2many:product_categories;"`
}

func (CategoryModel) TableName() string {
	return "categories"
}

// StyleModel maps to the styles table
type StyleModel struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"column:name;type:varchar(255);not null;unique"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt time.Time `gorm:"column:updated_at;autoUpdateTime"`

	Products []ProductModel `gorm:"many2many:product_styles;"`
}

func (StyleModel) TableName() string {
	return "styles"
}

// BrandModel maps to the brands table
type BrandModel struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"type:varchar(255);not null;uniqueIndex"`
	LogoURL   string    `gorm:"column:logo_url;type:varchar(255)"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	Products []ProductModel `gorm:"foreignKey:BrandID"`
}

func (BrandModel) TableName() string { return "brands" }

// ProductModel maps to the products table
type ProductModel struct {
	ID          uint      `gorm:"primaryKey"`
	Name        string    `gorm:"column:name;type:varchar(255);not null"`
	Price       float64   `gorm:"column:price;type:decimal(10,2);not null;default:0"`
	DiscountPct int       `gorm:"column:discount_pct;default:0"`
	PriceAfter  float64   `gorm:"column:price_after;type:decimal(10,2);not null;default:0"`
	AgeRange    string    `gorm:"column:age_range;type:varchar(50)"`
	Description string    `gorm:"column:description;type:text"`
	ImageURL    string    `gorm:"column:image_url;type:varchar(255)"`
	IsHotTrend  bool      `gorm:"column:is_hot_trend;default:false"`
	Status      string    `gorm:"column:status;type:varchar(20);default:'ACTIVE'"`
	CreatedAt   time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;autoUpdateTime"`

	BrandID *uint       `gorm:"index"`
	Brand   *BrandModel `gorm:"foreignKey:BrandID"`

	Variants   []ProductVariantModel `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE"`
	Categories []CategoryModel       `gorm:"many2many:product_categories;"`
	Styles     []StyleModel          `gorm:"many2many:product_styles;"`
}

func (ProductModel) TableName() string {
	return "products"
}

// ColorModel maps to the colors table
type ColorModel struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"type:varchar(50);not null;unique"`
	HexCode   string    `gorm:"type:varchar(7);not null;unique"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`
}

func (ColorModel) TableName() string {
	return "colors"
}

// New schema models
type ProductColorModel struct {
	ID        uint      `gorm:"primaryKey"`
	ProductID uint      `gorm:"not null;uniqueIndex:ux_product_color,priority:1"`
	ColorHex  string    `gorm:"type:varchar(7);not null;uniqueIndex:ux_product_color,priority:2"`
	ColorName string    `gorm:"type:varchar(50);not null"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	Images []ProductColorImageModel `gorm:"foreignKey:ProductColorID;constraint:OnDelete:CASCADE"`
}

func (ProductColorModel) TableName() string { return "product_colors" }

type ProductColorImageModel struct {
	ID             uint      `gorm:"primaryKey"`
	ProductColorID uint      `gorm:"not null;index"`
	ImageURL       string    `gorm:"type:varchar(255);not null"`
	SortOrder      int       `gorm:"default:0"`
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime"`
}

func (ProductColorImageModel) TableName() string { return "product_color_images" }

// ProductVariantModel maps to the product_variants table
type ProductVariantModel struct {
	ID             uint              `gorm:"primaryKey"`
	ProductID      uint              `gorm:"not null"`
	Product        ProductModel      `gorm:"foreignKey:ProductID"`
	ProductColorID uint              `gorm:"not null;uniqueIndex:ux_color_size,priority:1"`
	ProductColor   ProductColorModel `gorm:"foreignKey:ProductColorID"`
	SizeCode       string            `gorm:"column:size_code;type:varchar(10);not null;uniqueIndex:ux_color_size,priority:2"`
	Stock          int               `gorm:"not null"`
	Sku            string            `gorm:"type:varchar(100);unique;not null"`
	CreatedAt      time.Time         `gorm:"autoCreateTime"`
	UpdatedAt      time.Time         `gorm:"autoUpdateTime"`
}

func (ProductVariantModel) TableName() string {
	return "product_variants"
}

// ProductStatsModel maps to the product_stats table
type ProductStatsModel struct {
	ProductID   uint      `gorm:"primaryKey"`
	TotalStock  int       `gorm:"column:total_stock;default:0"`
	ViewCount   int       `gorm:"column:view_count;default:0"`
	SoldCount   int       `gorm:"column:sold_count;default:0"`
	RatingAvg   float64   `gorm:"column:rating_avg;type:decimal(10,2);default:0"`
	RatingCount int       `gorm:"column:rating_count;default:0"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
}

func (ProductStatsModel) TableName() string { return "product_stats" }
