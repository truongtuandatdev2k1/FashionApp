package repositories

import (
	"context"
	"errors"

	cen "myfashion/internal/modules/profile/entities"
	psvc "myfashion/internal/modules/profile/services"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type customerRepo struct{ db *gorm.DB }

func NewCustomerRepo(db *gorm.DB) psvc.CustomerProfileRepository { return &customerRepo{db: db} }

func (r *customerRepo) GetByUserID(ctx context.Context, userID uint) (*cen.CustomerProfile, error) {
	var m CustomerProfileModel
	if err := r.db.WithContext(ctx).First(&m, "user_id = ?", userID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return toCustomerEntity(&m), nil
}

func (r *customerRepo) Upsert(ctx context.Context, p *cen.CustomerProfile) error {
	m := toCustomerModel(p)
	return r.db.WithContext(ctx).Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"full_name", "age", "gender", "address", "img_url"}),
	}).Create(m).Error
}
