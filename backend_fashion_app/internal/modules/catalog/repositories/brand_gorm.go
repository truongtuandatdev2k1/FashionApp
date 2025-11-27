package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"
	"strings"

	"gorm.io/gorm"
)

type BrandRepository struct {
	db *gorm.DB
}

func NewBrandRepository(db *gorm.DB) *BrandRepository {
	return &BrandRepository{db: db}
}

func (r *BrandRepository) Create(ctx context.Context, brand *entities.Brand) error {
	model := BrandEntityToModel(brand)
	result := r.db.WithContext(ctx).Create(model)
	if result.Error != nil {
		return result.Error
	}
	brand.ID = model.ID // Update entity with the new ID
	return nil
}

func (r *BrandRepository) GetByID(ctx context.Context, id uint) (*entities.Brand, error) {
	var model BrandModel
	if err := r.db.WithContext(ctx).First(&model, id).Error; err != nil {
		return nil, err
	}
	return model.ToEntity(), nil
}

func (r *BrandRepository) List(ctx context.Context, q string, limit, offset int) ([]*entities.Brand, int64, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	dbq := r.db.WithContext(ctx).Model(&BrandModel{})
	if q != "" {
		like := "%" + strings.TrimSpace(q) + "%"
		dbq = dbq.Where("name LIKE ?", like)
	}
	var total int64
	if err := dbq.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var items []BrandModel
	if err := dbq.Order("created_at DESC").Limit(limit).Offset(offset).Find(&items).Error; err != nil {
		return nil, 0, err
	}

	var entityList []*entities.Brand
	for _, item := range items {
		entityList = append(entityList, item.ToEntity())
	}

	return entityList, total, nil
}

func (r *BrandRepository) Update(ctx context.Context, brand *entities.Brand) error {
	model := BrandEntityToModel(brand)
	return r.db.WithContext(ctx).Model(&BrandModel{}).Where("id = ?", model.ID).Updates(map[string]any{
		"name":     model.Name,
		"logo_url": model.LogoURL,
	}).Error
}

func (r *BrandRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&BrandModel{}, id).Error
}
