package repositories

import (
	"context"

	"gorm.io/gorm"
)

type UserStatusRepository struct {
	db *gorm.DB
}

func NewUserStatusRepository(db *gorm.DB) *UserStatusRepository {
	return &UserStatusRepository{db: db}
}

func (r *UserStatusRepository) IsActive(ctx context.Context, userID uint) (bool, error) {
	var u UserModel
	if err := r.db.WithContext(ctx).Select("is_active").Where("id = ?", userID).First(&u).Error; err != nil {
		return false, err
	}
	return u.IsActive, nil
}
