package services

import (
	"context"
	"errors"
	"myfashion/internal/modules/profile/entities"
)

type ProfileService struct {
	customerRepo CustomerProfileRepository
	shopRepo     ShopProfileRepository
}

func NewProfileService(cRepo CustomerProfileRepository, sRepo ShopProfileRepository) *ProfileService {
	return &ProfileService{customerRepo: cRepo, shopRepo: sRepo}
}

func (s *ProfileService) GetMine(ctx context.Context, role string, uid uint) (any, error) {
	switch role {
	case "customer":
		return s.customerRepo.GetByUserID(ctx, uid)
	case "shop":
		return s.shopRepo.GetByUserID(ctx, uid)
	default:
		return nil, errors.New("unsupported role")
	}
}

func (s *ProfileService) UpsertMine(ctx context.Context, role string, uid uint, payload any) error {
	switch role {
	case "customer":
		p, ok := payload.(*entities.CustomerProfile)
		if !ok {
			return errors.New("invalid payload")
		}
		p.UserID = uid

		// Lấy hồ sơ hiện có (nếu có)
		existing, _ := s.customerRepo.GetByUserID(ctx, uid)
		if existing == nil {
			// Tạo mới: gán hạng mặc định
			p.Tier = "bronze"
			return s.customerRepo.Upsert(ctx, p)
		}

		// Cập nhật: chỉ thay đổi các trường được cung cấp
		existing.FullName = p.FullName
		existing.Age = p.Age
		existing.Gender = p.Gender
		existing.Address = p.Address
		if p.ImgURL != "" { // Chỉ cập nhật ImgURL nếu nó không rỗng
			existing.ImgURL = p.ImgURL
		}

		return s.customerRepo.Upsert(ctx, existing)
	case "shop":
		p, ok := payload.(*entities.ShopProfile)
		if !ok {
			return errors.New("invalid payload")
		}
		p.UserID = uid

		// Lấy hồ sơ hiện có (nếu có)
		existing, _ := s.shopRepo.GetByUserID(ctx, uid)
		if existing == nil {
			// Tạo mới
			return s.shopRepo.Upsert(ctx, p)
		}

		// Cập nhật: chỉ thay đổi các trường được cung cấp
		existing.ShopName = p.ShopName
		existing.Address = p.Address
		if p.ImgURL != "" { // Chỉ cập nhật ImgURL nếu nó không rỗng
			existing.ImgURL = p.ImgURL
		}

		return s.shopRepo.Upsert(ctx, existing)
	default:
		return errors.New("unsupported role")
	}
}
