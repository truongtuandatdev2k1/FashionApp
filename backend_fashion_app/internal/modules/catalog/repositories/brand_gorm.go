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

type brandWithCountModel struct {
	BrandModel
	Counts int64 `gorm:"column:counts"`
}

func (r *BrandRepository) List(ctx context.Context, q string, limit, offset int) ([]*entities.Brand, int64, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	// base query (for filtering + counting)
	dbq := r.db.WithContext(ctx).Model(&BrandModel{})
	if q != "" {
		like := "%" + strings.TrimSpace(q) + "%"
		dbq = dbq.Where("name LIKE ?", like)
	}

	var total int64
	if err := dbq.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// list with counts
	listQ := r.db.WithContext(ctx).
		Table("brands").
		Select("brands.*, COUNT(products.id) AS counts").
		Joins("LEFT JOIN products ON products.brand_id = brands.id")
	if q != "" {
		like := "%" + strings.TrimSpace(q) + "%"
		listQ = listQ.Where("brands.name LIKE ?", like)
	}

	var items []brandWithCountModel
	if err := listQ.
		Group("brands.id").
		Order("brands.created_at DESC").
		Limit(limit).
		Offset(offset).
		Scan(&items).Error; err != nil {
		return nil, 0, err
	}

	var entityList []*entities.Brand
	for _, item := range items {
		b := item.BrandModel.ToEntity()
		b.Counts = item.Counts
		entityList = append(entityList, b)
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
