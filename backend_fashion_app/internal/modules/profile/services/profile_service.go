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
		return s.customerRepo.Upsert(ctx, p)
	case "shop":
		p, ok := payload.(*entities.ShopProfile)
		if !ok {
			return errors.New("invalid payload")
		}
		p.UserID = uid
		return s.shopRepo.Upsert(ctx, p)
	default:
		return errors.New("unsupported role")
	}
}
