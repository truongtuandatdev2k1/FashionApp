package services

import (
	"context"
	cen "myfashion/internal/modules/profile/entities"
)

type CustomerProfileRepository interface {
	GetByUserID(ctx context.Context, userID uint) (*cen.CustomerProfile, error)
	Upsert(ctx context.Context, p *cen.CustomerProfile) error
}
type ShopProfileRepository interface {
	GetByUserID(ctx context.Context, userID uint) (*cen.ShopProfile, error)
	Upsert(ctx context.Context, p *cen.ShopProfile) error
}
