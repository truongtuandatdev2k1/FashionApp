package repositories

import (
	"context"
	"errors"
	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type productColorGormRepo struct{ db *gorm.DB }

func NewProductColorGormRepo(db *gorm.DB) *productColorGormRepo { return &productColorGormRepo{db: db} }

func (r *productColorGormRepo) FindByProductAndHex(ctx context.Context, productID uint, hex string) (*entities.ProductColor, error) {
	var m ProductColorModel
	if err := r.db.WithContext(ctx).Where("product_id = ? AND color_hex = ?", productID, hex).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &entities.ProductColor{ID: m.ID, ProductID: m.ProductID, ColorHex: m.ColorHex, ColorName: m.ColorName, CreatedAt: m.CreatedAt, UpdatedAt: m.UpdatedAt}, nil
}

func (r *productColorGormRepo) Create(ctx context.Context, color *entities.ProductColor) error {
	m := &ProductColorModel{ProductID: color.ProductID, ColorHex: color.ColorHex, ColorName: color.ColorName}
	if err := r.db.WithContext(ctx).Create(m).Error; err != nil {
		return err
	}
	color.ID = m.ID
	color.CreatedAt = m.CreatedAt
	color.UpdatedAt = m.UpdatedAt
	return nil
}
