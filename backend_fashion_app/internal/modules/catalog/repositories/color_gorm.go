package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type ColorGormRepo struct {
	db *gorm.DB
}

func NewColorGormRepo(db *gorm.DB) *ColorGormRepo {
	return &ColorGormRepo{db: db}
}

func (r *ColorGormRepo) Create(ctx context.Context, color *entities.Color) error {
	model := &ColorModel{
		Name:    color.Name,
		HexCode: color.HexCode,
	}
	if err := r.db.WithContext(ctx).Create(model).Error; err != nil {
		return err
	}
	color.ID = model.ID
	return nil
}

func (r *ColorGormRepo) GetByID(ctx context.Context, id uint) (*entities.Color, error) {
	var model ColorModel
	if err := r.db.WithContext(ctx).First(&model, id).Error; err != nil {
		return nil, err
	}
	return &entities.Color{ID: model.ID, Name: model.Name, HexCode: model.HexCode}, nil
}

func (r *ColorGormRepo) GetAll(ctx context.Context) ([]*entities.Color, error) {
	var models []ColorModel
	if err := r.db.WithContext(ctx).Find(&models).Error; err != nil {
		return nil, err
	}

	colors := make([]*entities.Color, len(models))
	for i, model := range models {
		colors[i] = &entities.Color{ID: model.ID, Name: model.Name, HexCode: model.HexCode}
	}
	return colors, nil
}

func (r *ColorGormRepo) Update(ctx context.Context, color *entities.Color) error {
	model := &ColorModel{
		ID:      color.ID,
		Name:    color.Name,
		HexCode: color.HexCode,
	}
	return r.db.WithContext(ctx).Save(model).Error
}

func (r *ColorGormRepo) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&ColorModel{}, id).Error
}

