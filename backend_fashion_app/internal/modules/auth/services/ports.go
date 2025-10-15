package services

import (
	"context"
	"myfashion/internal/modules/auth/entities"
)

type UserRepository interface {
	Create(ctx context.Context, u *entities.User) error
	GetByEmail(ctx context.Context, email string) (*entities.User, error)
	GetByCredential(ctx context.Context, credential string) (*entities.User, error)
	GetByID(ctx context.Context, id uint) (*entities.User, error)
	GetByGoogleSub(ctx context.Context, sub string) (*entities.User, error)
}

type RefreshTokenRepository interface {
	Create(ctx context.Context, rt *entities.RefreshToken) error
	GetByHash(ctx context.Context, hash string) (*entities.RefreshToken, error)
	RevokeByHash(ctx context.Context, hash string) error
	RevokeAllByUser(ctx context.Context, userID uint) error
	DeleteExpired(ctx context.Context) error
}
