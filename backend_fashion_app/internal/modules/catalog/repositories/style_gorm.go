package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type styleGormRepo struct {
	db *gorm.DB
}

func NewStyleGormRepo(db *gorm.DB) *styleGormRepo {
	return &styleGormRepo{db: db}
}

func (r *styleGormRepo) Create(ctx context.Context, style *entities.Style) error {
	model := StyleEntityToModel(style)
	err := r.db.WithContext(ctx).Create(model).Error
	if err != nil {
		return err
	}
	*style = *model.ToEntity()
	return nil
}

func (r *styleGormRepo) GetByID(ctx context.Context, id uint) (*entities.Style, error) {
	var model StyleModel
	if err := r.db.WithContext(ctx).First(&model, id).Error; err != nil {
		return nil, err
	}
	return model.ToEntity(), nil
}

func (r *styleGormRepo) GetAll(ctx context.Context) ([]*entities.Style, error) {
	var models []StyleModel
	if err := r.db.WithContext(ctx).Find(&models).Error; err != nil {
		return nil, err
	}

	var entities []*entities.Style
	for _, model := range models {
		entities = append(entities, model.ToEntity())
	}
	return entities, nil
}

func (r *styleGormRepo) Update(ctx context.Context, style *entities.Style) error {
	model := StyleEntityToModel(style)
	return r.db.WithContext(ctx).Save(model).Error
}

func (r *styleGormRepo) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&StyleModel{}, id).Error
}
