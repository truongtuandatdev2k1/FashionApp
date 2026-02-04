package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"
	"strings"
	"time"

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

	// GORM sẽ tự động tạo các bản ghi trong bảng trung gian
	err := r.db.WithContext(ctx).Create(model).Error
	if err != nil {
		return err
	}
	product.ID = model.ID
	return nil
}

func (r *productGormRepo) GetByID(ctx context.Context, id uint) (*entities.Product, error) {
	var model ProductModel
	// Sử dụng Preload để tải các mối quan hệ
	if err := r.db.WithContext(ctx).Preload("Brand").Preload("Categories").Preload("Styles").Preload("Variants.ProductColor.Images").First(&model, id).Error; err != nil {
		return nil, err
	}

	// Chuyển đổi các model con sang entity
	var categories []entities.Category
	for _, catModel := range model.Categories {
		categories = append(categories, *catModel.ToEntity())
	}

	var styles []entities.Style
	for _, styleModel := range model.Styles {
		styles = append(styles, *styleModel.ToEntity())
	}

	return model.ToEntity(categories, styles), nil
}

func (r *productGormRepo) GetAll(ctx context.Context) ([]*entities.Product, error) {
	var models []ProductModel
	if err := r.db.WithContext(ctx).Preload("Categories").Preload("Styles").Preload("Variants.ProductColor").Find(&models).Error; err != nil {
		return nil, err
	}

	var productEntities []*entities.Product
	for _, model := range models {
		// Chuyển đổi đã có Preload
		var categories []entities.Category
		for _, catModel := range model.Categories {
			categories = append(categories, *catModel.ToEntity())
		}
		var styles []entities.Style
		for _, styleModel := range model.Styles {
			styles = append(styles, *styleModel.ToEntity())
		}
		productEntities = append(productEntities, model.ToEntity(categories, styles))
	}

	return productEntities, nil
}

func (r *productGormRepo) GetAllPaginated(ctx context.Context, filter string, page, limit int, brandID uint, status string) ([]*entities.Product, int64, error) {
	db := r.db.WithContext(ctx).Model(&ProductModel{})

	if brandID != 0 {
		db = db.Where("brand_id = ?", brandID)
	}

	// Optional status filter (case-insensitive)
	if status != "" {
		db = db.Where("UPPER(status) = ?", strings.ToUpper(status))
	}

	// Áp dụng bộ lọc
	switch filter {
	case "hottrend":
		db = db.Where("is_hot_trend = ?", true)
	case "new":
		oneMonthAgo := time.Now().AddDate(0, -1, 0)
		db = db.Where("created_at >= ?", oneMonthAgo)
	case "bestseller":
		subQuery := r.db.Table("order_items").Select("product_id, SUM(quantity) as total_sold").Group("product_id")
		db = db.Joins("LEFT JOIN (?) as sales ON products.id = sales.product_id", subQuery).Order("sales.total_sold DESC")
	default:
		db = db.Order("created_at DESC")
	}

	var total int64
	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit

	var models []ProductModel
	if err := db.Preload("Categories").Preload("Styles").Offset(offset).Limit(limit).Find(&models).Error; err != nil {
		return nil, 0, err
	}

	var productEntities []*entities.Product
	for _, model := range models {
		var categories []entities.Category
		for _, catModel := range model.Categories {
			categories = append(categories, *catModel.ToEntity())
		}
		var styles []entities.Style
		for _, styleModel := range model.Styles {
			styles = append(styles, *styleModel.ToEntity())
		}
		productEntities = append(productEntities, model.ToEntity(categories, styles))
	}

	return productEntities, total, nil
}

func (r *productGormRepo) Update(ctx context.Context, product *entities.Product) error {
	model := ProductEntityToModel(product)

	tx := r.db.WithContext(ctx).Begin()

	if err := tx.Model(&model).Updates(model).Error; err != nil {
		tx.Rollback()
		return err
	}

	// Cập nhật quan hệ nhiều-nhiều
	if product.Categories != nil {
		if err := tx.Model(&model).Association("Categories").Replace(model.Categories); err != nil {
			tx.Rollback()
			return err
		}
	}

	if product.Styles != nil {
		if err := tx.Model(&model).Association("Styles").Replace(model.Styles); err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit().Error
}

func (r *productGormRepo) Delete(ctx context.Context, id uint) error {
	// Soft delete: set status = 'INACTIVE' (do not delete history)
	return r.db.WithContext(ctx).Model(&ProductModel{}).Where("id = ?", id).Update("status", "INACTIVE").Error
}
