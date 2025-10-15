package repositories

import (
	"context"
	"errors"

	cen "myfashion/internal/modules/profile/entities"
	psvc "myfashion/internal/modules/profile/services"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type shopRepo struct{ db *gorm.DB }

func NewShopRepo(db *gorm.DB) psvc.ShopProfileRepository { return &shopRepo{db: db} }

func (r *shopRepo) GetByUserID(ctx context.Context, userID uint) (*cen.ShopProfile, error) {
	var m ShopProfileModel
	if err := r.db.WithContext(ctx).First(&m, "user_id = ?", userID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return toShopEntity(&m), nil
}

func (r *shopRepo) Upsert(ctx context.Context, p *cen.ShopProfile) error {
	m := toShopModel(p)
	return r.db.WithContext(ctx).Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"shop_name", "address"}),
	}).Create(m).Error
}
