package repositories

import (
	"context"
	"errors"

	"myfashion/internal/modules/auth/entities"
	"myfashion/internal/modules/auth/services"

	"gorm.io/gorm"
)

type userRepo struct{ db *gorm.DB }

func NewUserRepository(db *gorm.DB) services.UserRepository { return &userRepo{db: db} }

func (r *userRepo) Create(ctx context.Context, u *entities.User) error {
	m := toModel(u)
	if err := r.db.WithContext(ctx).Create(m).Error; err != nil {
		return err
	}
	u.ID, u.CreatedAt, u.UpdatedAt = m.ID, m.CreatedAt, m.UpdatedAt
	return nil
}
func (r *userRepo) GetByEmail(ctx context.Context, email string) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).Where("email = ?", email).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return toEntity(&m), nil
}
func (r *userRepo) GetByID(ctx context.Context, id uint) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).First(&m, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return toEntity(&m), nil
}
func (r *userRepo) GetByCredential(ctx context.Context, credential string) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).Where("email = ? OR phone_number = ?", credential, credential).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return toEntity(&m), nil
}

func (r *userRepo) GetByGoogleSub(ctx context.Context, sub string) (*entities.User, error) {
	if sub == "" {
		return nil, nil
	}
	var m UserModel
	if err := r.db.WithContext(ctx).Where("google_sub = ?", sub).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return toEntity(&m), nil
}
