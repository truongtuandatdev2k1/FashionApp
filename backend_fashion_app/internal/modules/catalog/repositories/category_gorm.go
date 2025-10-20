package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type categoryGormRepo struct {
	db *gorm.DB
}

func NewCategoryGormRepo(db *gorm.DB) *categoryGormRepo {
	return &categoryGormRepo{db: db}
}

func (r *categoryGormRepo) Create(ctx context.Context, category *entities.Category) error {
	model := CategoryEntityToModel(category)
	err := r.db.WithContext(ctx).Create(model).Error
	if err != nil {
		return err
	}
	*category = *model.ToEntity()
	return nil
}

func (r *categoryGormRepo) GetByID(ctx context.Context, id uint) (*entities.Category, error) {
	var model CategoryModel
	if err := r.db.WithContext(ctx).First(&model, id).Error; err != nil {
		return nil, err
	}
	return model.ToEntity(), nil
}

func (r *categoryGormRepo) GetAll(ctx context.Context) ([]*entities.Category, error) {
	var models []CategoryModel
	if err := r.db.WithContext(ctx).Find(&models).Error; err != nil {
		return nil, err
	}

	var entities []*entities.Category
	for _, model := range models {
		entities = append(entities, model.ToEntity())
	}
	return entities, nil
}

func (r *categoryGormRepo) Update(ctx context.Context, category *entities.Category) error {
	model := CategoryEntityToModel(category)
	return r.db.WithContext(ctx).Save(model).Error
}

func (r *categoryGormRepo) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&CategoryModel{}, id).Error
}
