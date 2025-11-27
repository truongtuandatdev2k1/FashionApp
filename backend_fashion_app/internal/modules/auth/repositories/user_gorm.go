package repositories

import (
	"context"
	"errors"

	"myfashion/internal/modules/auth/entities"

	"gorm.io/gorm"
)

// UserRepository chịu trách nhiệm tương tác với DB cho User.
type UserRepository struct{ db *gorm.DB }

// NewUserRepository tạo một instance mới của UserRepository.
func NewUserRepository(db *gorm.DB) *UserRepository { return &UserRepository{db: db} }

// Create tạo một user mới trong DB.
func (r *UserRepository) Create(ctx context.Context, u *entities.User) error {
	m := ToUserModel(u)
	if err := r.db.WithContext(ctx).Create(m).Error; err != nil {
		return err
	}
	u.ID, u.CreatedAt, u.UpdatedAt = m.ID, m.CreatedAt, m.UpdatedAt
	return nil
}

// GetByEmail tìm một user bằng email.
func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).Where("email = ?", email).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return ToUserEntity(&m), nil
}

// GetByPhone tìm một user bằng số điện thoại.
func (r *UserRepository) GetByPhone(ctx context.Context, phone string) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).Where("phone_number = ?", phone).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return ToUserEntity(&m), nil
}

// GetByID tìm một user bằng ID.
func (r *UserRepository) GetByID(ctx context.Context, id uint) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).First(&m, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return ToUserEntity(&m), nil
}

// GetByCredential tìm một user bằng email hoặc số điện thoại.
func (r *UserRepository) GetByCredential(ctx context.Context, credential string) (*entities.User, error) {
	var m UserModel
	if err := r.db.WithContext(ctx).Where("email = ? OR phone_number = ?", credential, credential).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return ToUserEntity(&m), nil
}
