package repositories

import (
	"context"
	"errors"
	"myfashion/internal/modules/catalog/services"

	"gorm.io/gorm"
)

type productVariantGormRepo struct{ db *gorm.DB }

func NewProductVariantGormRepo(db *gorm.DB) *productVariantGormRepo {
	return &productVariantGormRepo{db: db}
}

// UpsertMany upserts variants by (product_color_id, size_code) and returns total stock for the product
func (r *productVariantGormRepo) UpsertMany(ctx context.Context, productID uint, items []services.ProductVariantUpsert) (int, error) {
	if len(items) == 0 {
		// total stock may still need recompute; compute directly
		var total int64
		if err := r.db.WithContext(ctx).Model(&ProductVariantModel{}).Where("product_id = ?", productID).Select("COALESCE(SUM(stock),0)").Scan(&total).Error; err != nil {
			return 0, err
		}
		return int(total), nil
	}

	tx := r.db.WithContext(ctx).Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	for _, it := range items {
		var existing ProductVariantModel
		err := tx.Where("product_id = ? AND product_color_id = ? AND size_code = ?", productID, it.ProductColorID, it.SizeCode).
			First(&existing).Error
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				create := &ProductVariantModel{
					ProductID:      productID,
					ProductColorID: it.ProductColorID,
					SizeCode:       it.SizeCode,
					Stock:          it.Stock,
					Sku:            it.Sku,
				}
				if err := tx.Create(create).Error; err != nil {
					tx.Rollback()
					return 0, err
				}
			} else {
				tx.Rollback()
				return 0, err
			}
		} else {
			// update
			existing.Stock = it.Stock
			existing.Sku = it.Sku
			if err := tx.Model(&existing).Updates(map[string]any{
				"stock": existing.Stock,
				"sku":   existing.Sku,
			}).Error; err != nil {
				tx.Rollback()
				return 0, err
			}
		}
	}

	// compute total
	var total int64
	if err := tx.Model(&ProductVariantModel{}).Where("product_id = ?", productID).Select("COALESCE(SUM(stock),0)").Scan(&total).Error; err != nil {
		tx.Rollback()
		return 0, err
	}

	if err := tx.Commit().Error; err != nil {
		return 0, err
	}
	return int(total), nil
}
