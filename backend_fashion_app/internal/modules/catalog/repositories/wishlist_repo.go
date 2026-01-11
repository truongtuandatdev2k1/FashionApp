package repositories

import (
	"context"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type WishlistRepository struct {
	db *gorm.DB
}

func NewWishlistRepository(db *gorm.DB) *WishlistRepository {
	return &WishlistRepository{db: db}
}

func (r *WishlistRepository) Add(ctx context.Context, userID, productID uint) error {
	return r.db.WithContext(ctx).
		Clauses(clause.OnConflict{DoNothing: true}).
		Create(&WishlistItemModel{UserID: userID, ProductID: productID}).Error
}

func (r *WishlistRepository) Remove(ctx context.Context, userID, productID uint) error {
	return r.db.WithContext(ctx).
		Where("user_id = ? AND product_id = ?", userID, productID).
		Delete(&WishlistItemModel{}).Error
}

func (r *WishlistRepository) Exists(ctx context.Context, userID, productID uint) (bool, error) {
	var cnt int64
	if err := r.db.WithContext(ctx).Model(&WishlistItemModel{}).
		Where("user_id = ? AND product_id = ?", userID, productID).
		Count(&cnt).Error; err != nil {
		return false, err
	}
	return cnt > 0, nil
}

func (r *WishlistRepository) ListProductIDs(ctx context.Context, userID uint, limit, offset int) ([]uint, int64, error) {
	q := r.db.WithContext(ctx).Model(&WishlistItemModel{}).Where("user_id = ?", userID).Order("created_at DESC")
	var total int64
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	if offset < 0 {
		offset = 0
	}
	var ids []uint
	if err := q.Limit(limit).Offset(offset).Pluck("product_id", &ids).Error; err != nil {
		return nil, 0, err
	}
	return ids, total, nil
}

