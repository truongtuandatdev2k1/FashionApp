package repositories

import (
	"context"

	"gorm.io/gorm"
)

type UserRepositoryAdapter struct {
	db *gorm.DB
}

func NewUserRepositoryAdapter(db *gorm.DB) *UserRepositoryAdapter {
	return &UserRepositoryAdapter{db: db}
}

func (r *UserRepositoryAdapter) ListUserIDs(ctx context.Context, role string) ([]uint, error) {
	var ids []uint
	q := r.db.WithContext(ctx).Model(&UserModel{}).Select("id")
	if role != "" {
		q = q.Where("role = ?", role)
	}
	if err := q.Find(&ids).Error; err != nil {
		return nil, err
	}
	return ids, nil
}

type UserModel struct {
	ID   uint
	Role string
}

func (UserModel) TableName() string { return "users" }

