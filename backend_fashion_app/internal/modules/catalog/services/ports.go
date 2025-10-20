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
}

// StyleRepository defines the methods for interacting with style data.
type StyleRepository interface {
	Create(ctx context.Context, style *entities.Style) error
	GetByID(ctx context.Context, id uint) (*entities.Style, error)
	GetAll(ctx context.Context) ([]*entities.Style, error)
	Update(ctx context.Context, style *entities.Style) error
	Delete(ctx context.Context, id uint) error
}

// ProductRepository defines the methods for interacting with product data.
type ProductRepository interface {
	Create(ctx context.Context, product *entities.Product) error
	GetByID(ctx context.Context, id uint) (*entities.Product, error)
	GetAll(ctx context.Context) ([]*entities.Product, error)
	Update(ctx context.Context, product *entities.Product) error
	Delete(ctx context.Context, id uint) error
	CreateImage(ctx context.Context, image *entities.ProductImage) error
}
