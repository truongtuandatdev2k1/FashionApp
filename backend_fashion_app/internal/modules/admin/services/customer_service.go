package services

import (
	"context"
	"time"

	"myfashion/internal/common/security"
	"myfashion/internal/modules/admin/api"
	"myfashion/internal/modules/admin/repositories"

	"gorm.io/gorm"
)

type CustomerService struct {
	repo *repositories.CustomerRepository
}

func NewCustomerService(repo *repositories.CustomerRepository) *CustomerService {
	return &CustomerService{repo: repo}
}

func (s *CustomerService) List(ctx context.Context, q string, limit, offset int) (*api.CustomerListResponse, error) {
	users, total, err := s.repo.ListCustomers(ctx, q, limit, offset)
	if err != nil {
		return nil, err
	}
	items := make([]api.CustomerListItem, 0, len(users))
	for _, u := range users {
		items = append(items, api.CustomerListItem{
			ID:          u.ID,
			Email:       u.Email,
			PhoneNumber: u.PhoneNumber,
			IsActive:    u.IsActive,
			CreatedAt:   u.CreatedAt.Format(time.RFC3339),
		})
	}
	return &api.CustomerListResponse{Items: items, Total: total, Limit: limit, Offset: offset}, nil
}

func (s *CustomerService) Detail(ctx context.Context, id uint) (*api.CustomerDetailResponse, error) {
	u, err := s.repo.GetCustomerByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return &api.CustomerDetailResponse{
		ID:          u.ID,
		Email:       u.Email,
		PhoneNumber: u.PhoneNumber,
		Role:        u.Role,
		IsActive:    u.IsActive,
		CreatedAt:   u.CreatedAt.Format(time.RFC3339),
		UpdatedAt:   u.UpdatedAt.Format(time.RFC3339),
	}, nil
}

func (s *CustomerService) UpdateStatus(ctx context.Context, id uint, isActive bool) error {
	return s.repo.UpdateIsActive(ctx, id, isActive)
}

func (s *CustomerService) ResetPassword(ctx context.Context, id uint, newPassword string) error {
	hash, err := (security.BcryptHasher{}).Hash(newPassword)
	if err != nil {
		return err
	}
	return s.repo.UpdatePasswordHash(ctx, id, hash)
}

// Ensure GORM error types are available to controller (avoid extra imports in controller)
func IsNotFound(err error) bool { return err == gorm.ErrRecordNotFound }

