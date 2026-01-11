package repositories

import (
	"context"

	"gorm.io/gorm"
)

type CustomerRepository struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) *CustomerRepository {
	return &CustomerRepository{db: db}
}

func (r *CustomerRepository) ListCustomers(ctx context.Context, q string, limit, offset int) ([]UserModel, int64, error) {
	db := r.db.WithContext(ctx).Model(&UserModel{}).Where("role = ?", "customer")
	if q != "" {
		like := "%" + q + "%"
		db = db.Where("email LIKE ? OR phone_number LIKE ?", like, like)
	}
	var total int64
	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var users []UserModel
	if err := db.Order("id DESC").Limit(limit).Offset(offset).Find(&users).Error; err != nil {
		return nil, 0, err
	}
	return users, total, nil
}

func (r *CustomerRepository) GetCustomerByID(ctx context.Context, id uint) (*UserModel, error) {
	var u UserModel
	if err := r.db.WithContext(ctx).Where("id = ? AND role = ?", id, "customer").First(&u).Error; err != nil {
		return nil, err
	}
	return &u, nil
}

func (r *CustomerRepository) UpdateIsActive(ctx context.Context, id uint, isActive bool) error {
	return r.db.WithContext(ctx).Model(&UserModel{}).Where("id = ? AND role = ?", id, "customer").Update("is_active", isActive).Error
}

func (r *CustomerRepository) UpdatePasswordHash(ctx context.Context, id uint, passwordHash string) error {
	return r.db.WithContext(ctx).Model(&UserModel{}).Where("id = ? AND role = ?", id, "customer").Update("password", passwordHash).Error
}

