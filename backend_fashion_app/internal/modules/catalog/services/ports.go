package services

import (
	"context"
	"myfashion/internal/modules/catalog/entities"
)

// CategoryRepository defines the methods for interacting with category data.
type CategoryRepository interface {
	Create(ctx context.Context, category *entities.Category) error
	GetByID(ctx context.Context, id uint) (*entities.Category, error)
	GetAll(ctx context.Context) ([]*entities.Category, error)
	Update(ctx context.Context, category *entities.Category) error
	Delete(ctx context.Context, id uint) error
	GetByIDs(ctx context.Context, ids []uint) ([]entities.Category, error)
}

// StyleRepository defines the methods for interacting with style data.
type StyleRepository interface {
	Create(ctx context.Context, style *entities.Style) error
	GetByID(ctx context.Context, id uint) (*entities.Style, error)
	GetAll(ctx context.Context) ([]*entities.Style, error)
	Update(ctx context.Context, style *entities.Style) error
	Delete(ctx context.Context, id uint) error
	GetByIDs(ctx context.Context, ids []uint) ([]entities.Style, error)
}

// ProductRepository defines the methods for interacting with product data.
type ProductRepository interface {
	Create(ctx context.Context, product *entities.Product) error
	GetByID(ctx context.Context, id uint) (*entities.Product, error)
	GetAll(ctx context.Context) ([]*entities.Product, error)
	GetAllPaginated(ctx context.Context, filter string, page, limit int) ([]*entities.Product, int64, error)
	Update(ctx context.Context, product *entities.Product) error
	Delete(ctx context.Context, id uint) error
}

// BrandRepository defines the methods for interacting with brand data.
type BrandRepository interface {
	Create(ctx context.Context, brand *entities.Brand) error
	GetByID(ctx context.Context, id uint) (*entities.Brand, error)
	List(ctx context.Context, q string, limit, offset int) ([]*entities.Brand, int64, error)
	Update(ctx context.Context, brand *entities.Brand) error
	Delete(ctx context.Context, id uint) error
}

// ColorRepository defines the methods for interacting with color data.
type ColorRepository interface {
	Create(ctx context.Context, color *entities.Color) error
	GetByID(ctx context.Context, id uint) (*entities.Color, error)
	GetAll(ctx context.Context) ([]*entities.Color, error)
	Update(ctx context.Context, color *entities.Color) error
	Delete(ctx context.Context, id uint) error
}

// --- New repos for variants/colors/images/stats ---

type ProductColorRepository interface {
	FindByProductAndHex(ctx context.Context, productID uint, hex string) (*entities.ProductColor, error)
	Create(ctx context.Context, color *entities.ProductColor) error
}

type ProductColorImageRepository interface {
	CreateMany(ctx context.Context, images []entities.ProductColorImage) error
}

type ProductVariantUpsert struct {
	ProductColorID uint
	SizeCode       string
	Stock          int
	Sku            string
}

type ProductVariantRepository interface {
	UpsertMany(ctx context.Context, productID uint, items []ProductVariantUpsert) (totalStock int, err error)
}

type ProductStatsRepository interface {
	UpsertTotalStock(ctx context.Context, productID uint, total int) error
}
