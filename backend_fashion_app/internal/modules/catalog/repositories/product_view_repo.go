package repositories

import (
	"context"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type ProductViewRepository interface {
	RecordView(ctx context.Context, userID, productID uint) error
	GetRecentViews(ctx context.Context, userID uint, limit int) ([]uint, error)
}

type productViewRepo struct {
	db *gorm.DB
}

func NewProductViewRepository(db *gorm.DB) ProductViewRepository {
	return &productViewRepo{db: db}
}

func (r *productViewRepo) RecordView(ctx context.Context, userID, productID uint) error {
	return r.db.WithContext(ctx).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "user_id"}, {Name: "product_id"}},
			DoUpdates: clause.AssignmentColumns([]string{"viewed_at"}),
		}).
		Create(&ProductViewModel{UserID: userID, ProductID: productID, ViewedAt: time.Now()}).Error
}

func (r *productViewRepo) GetRecentViews(ctx context.Context, userID uint, limit int) ([]uint, error) {
	var productIDs []uint
	err := r.db.WithContext(ctx).
		Model(&ProductViewModel{}).
		Where("user_id = ?", userID).
		Order("viewed_at DESC").
		Limit(limit).
		Pluck("product_id", &productIDs).Error

	return productIDs, err
}
