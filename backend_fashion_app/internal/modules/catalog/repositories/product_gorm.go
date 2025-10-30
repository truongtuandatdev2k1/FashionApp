package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"
	"strings"

	"gorm.io/gorm"
)

type productGormRepo struct {
	db *gorm.DB
}

func NewProductGormRepo(db *gorm.DB) *productGormRepo {
	return &productGormRepo{db: db}
}

func (r *productGormRepo) Create(ctx context.Context, product *entities.Product) error {
	model := ProductEntityToModel(product)
	err := r.db.WithContext(ctx).Create(model).Error
	if err != nil {
		return err
	}
	product.ID = model.ID
	return nil
}

func (r *productGormRepo) GetByID(ctx context.Context, id uint) (*entities.Product, error) {
	var model ProductModel
	if err := r.db.WithContext(ctx).First(&model, id).Error; err != nil {
		return nil, err
	}

	// Fetch categories
	var categories []entities.Category
	if model.CategoryIDs != "" {
		var categoryModels []CategoryModel
		catIDs := strings.Split(model.CategoryIDs, ",")
		if err := r.db.WithContext(ctx).Where("id IN ?", catIDs).Find(&categoryModels).Error; err == nil {
			for _, catModel := range categoryModels {
				categories = append(categories, *catModel.ToEntity())
			}
		}
	}

	// Fetch styles
	var styles []entities.Style
	if model.StyleIDs != "" {
		var styleModels []StyleModel
		styleIDs := strings.Split(model.StyleIDs, ",")
		if err := r.db.WithContext(ctx).Where("id IN ?", styleIDs).Find(&styleModels).Error; err == nil {
			for _, styleModel := range styleModels {
				styles = append(styles, *styleModel.ToEntity())
			}
		}
	}

	// Fetch images
	var imageModels []ProductImageModel
	if err := r.db.WithContext(ctx).Where("product_id = ?", model.ID).Find(&imageModels).Error; err != nil {
		// Don't fail if images are not found, just return an empty slice
	}

	var images []entities.ProductImage
	for _, img := range imageModels {
		images = append(images, *img.ToEntity())
	}

	return model.ToEntity(categories, styles, images), nil
}

func (r *productGormRepo) GetAll(ctx context.Context) ([]*entities.Product, error) {
	var models []ProductModel
	if err := r.db.WithContext(ctx).Find(&models).Error; err != nil {
		return nil, err
	}

	var productEntities []*entities.Product
	for _, model := range models {
		product, err := r.GetByID(ctx, model.ID) // Reuse GetByID to load relations
		if err != nil {
			return nil, err
		}
		productEntities = append(productEntities, product)
	}

	return productEntities, nil
}

func (r *productGormRepo) GetAllPaginated(ctx context.Context, page, limit int) ([]*entities.Product, int64, error) {
	// Count total records
	var total int64
	if err := r.db.WithContext(ctx).Model(&ProductModel{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Calculate offset
	offset := (page - 1) * limit

	// Fetch paginated products
	var models []ProductModel
	if err := r.db.WithContext(ctx).
		Offset(offset).
		Limit(limit).
		Order("created_at DESC").
		Find(&models).Error; err != nil {
		return nil, 0, err
	}

	var productEntities []*entities.Product
	for _, model := range models {
		product, err := r.GetByID(ctx, model.ID) // Reuse GetByID to load relations
		if err != nil {
			return nil, 0, err
		}
		productEntities = append(productEntities, product)
	}

	return productEntities, total, nil
}

func (r *productGormRepo) Update(ctx context.Context, product *entities.Product) error {
	model := ProductEntityToModel(product)
	return r.db.WithContext(ctx).Model(&ProductModel{}).Where("id = ?", model.ID).Updates(model).Error
}

func (r *productGormRepo) Delete(ctx context.Context, id uint) error {
	// Also delete associated images
	// In a real-world scenario, you might want to use a transaction
	if err := r.db.WithContext(ctx).Where("product_id = ?", id).Delete(&ProductImageModel{}).Error; err != nil {
		return err
	}
	return r.db.WithContext(ctx).Delete(&ProductModel{}, id).Error
}

func (r *productGormRepo) CreateImage(ctx context.Context, image *entities.ProductImage) error {
	model := ProductImageEntityToModel(image)
	err := r.db.WithContext(ctx).Create(model).Error
	if err != nil {
		return err
	}
	*image = *model.ToEntity()
	return nil
}
