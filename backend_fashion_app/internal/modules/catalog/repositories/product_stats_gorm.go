package repositories

import (
	"context"

	"gorm.io/gorm"
)

type productStatsGormRepo struct{ db *gorm.DB }

func NewProductStatsGormRepo(db *gorm.DB) *productStatsGormRepo { return &productStatsGormRepo{db: db} }

func (r *productStatsGormRepo) UpsertTotalStock(ctx context.Context, productID uint, total int) error {
	var m ProductStatsModel
	err := r.db.WithContext(ctx).Where("product_id = ?", productID).First(&m).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			m = ProductStatsModel{ProductID: productID, TotalStock: total}
			return r.db.WithContext(ctx).Create(&m).Error
		}
		return err
	}
	return r.db.WithContext(ctx).Model(&m).Update("total_stock", total).Error
}
