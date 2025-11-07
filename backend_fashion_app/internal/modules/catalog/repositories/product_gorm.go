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

func (r *productGormRepo) GetAllPaginated(ctx context.Context, filter string, page, limit int) ([]*entities.Product, int64, error) {
	db := r.db.WithContext(ctx).Model(&ProductModel{})

	// Áp dụng bộ lọc
	switch filter {
	case "hottrend":
		db = db.Where("is_hot_trend = ?", true)
	case "new":
		// Sản phẩm mới trong vòng 1 tháng
		oneMonthAgo := time.Now().AddDate(0, -1, 0)
		db = db.Where("created_at >= ?", oneMonthAgo)
	case "bestseller":
		// Đây là một truy vấn phức tạp, đòi hỏi JOIN với dữ liệu từ module order.
		// Chúng ta sẽ join với một subquery để đếm số lượng đã bán.
		subQuery := r.db.Table("order_items").Select("product_id, SUM(quantity) as total_sold").Group("product_id")
		db = db.Joins("LEFT JOIN (?) as sales ON products.id = sales.product_id", subQuery).Order("sales.total_sold DESC")
	default:
		// Mặc định (all) sẽ sắp xếp theo ngày tạo mới nhất
		db = db.Order("created_at DESC")
	}

	// Đếm tổng số bản ghi sau khi áp dụng bộ lọc
	var total int64
	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Tính toán offset cho phân trang
	offset := (page - 1) * limit

	// Lấy danh sách sản phẩm đã phân trang và sắp xếp
	var models []ProductModel
	if err := db.Offset(offset).Limit(limit).Find(&models).Error; err != nil {
		return nil, 0, err
	}

	// Chuyển đổi models sang entities
	var productEntities []*entities.Product
	for _, model := range models {
		// Dùng GetByID để load các quan hệ (categories, styles, images)
		product, err := r.GetByID(ctx, model.ID)
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
