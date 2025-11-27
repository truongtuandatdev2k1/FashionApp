package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type productColorImageGormRepo struct{ db *gorm.DB }

func NewProductColorImageGormRepo(db *gorm.DB) *productColorImageGormRepo {
	return &productColorImageGormRepo{db: db}
}

func (r *productColorImageGormRepo) CreateMany(ctx context.Context, images []entities.ProductColorImage) error {
	if len(images) == 0 {
		return nil
	}
	// map to models
	m := make([]ProductColorImageModel, len(images))
	for i, it := range images {
		m[i] = ProductColorImageModel{
			ProductColorID: it.ProductColorID,
			ImageURL:       it.ImageURL,
			SortOrder:      it.SortOrder,
		}
	}
	return r.db.WithContext(ctx).Create(&m).Error
}
