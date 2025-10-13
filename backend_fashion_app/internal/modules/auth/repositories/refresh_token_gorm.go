package repositories

import (
	"context"
	"time"

	"myfashion/internal/modules/auth/entities"
	"myfashion/internal/modules/auth/services"

	"gorm.io/gorm"
)

type refreshTokenRepo struct{ db *gorm.DB }

func NewRefreshTokenRepository(db *gorm.DB) services.RefreshTokenRepository {
	return &refreshTokenRepo{db: db}
}

func (r *refreshTokenRepo) Create(ctx context.Context, rt *entities.RefreshToken) error {
	m := &RefreshTokenModel{
		UserID:    rt.UserID,
		TokenHash: rt.TokenHash,
		ExpiresAt: rt.ExpiresAt,
		Revoked:   rt.Revoked,
	}
	if err := r.db.WithContext(ctx).Create(m).Error; err != nil {
		return err
	}
	rt.ID, rt.CreatedAt, rt.UpdatedAt = m.ID, m.CreatedAt, m.UpdatedAt
	return nil
}

func (r *refreshTokenRepo) GetByHash(ctx context.Context, hash string) (*entities.RefreshToken, error) {
	var m RefreshTokenModel
	if err := r.db.WithContext(ctx).Where("token_hash = ?", hash).First(&m).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &entities.RefreshToken{
		ID:        m.ID,
		UserID:    m.UserID,
		TokenHash: m.TokenHash,
		ExpiresAt: m.ExpiresAt,
		Revoked:   m.Revoked,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
	}, nil
}

func (r *refreshTokenRepo) RevokeByHash(ctx context.Context, hash string) error {
	return r.db.WithContext(ctx).Model(&RefreshTokenModel{}).Where("token_hash = ?", hash).Update("revoked", true).Error
}

func (r *refreshTokenRepo) RevokeAllByUser(ctx context.Context, userID uint) error {
	return r.db.WithContext(ctx).Model(&RefreshTokenModel{}).Where("user_id = ? AND revoked = ?", userID, false).Update("revoked", true).Error
}

func (r *refreshTokenRepo) DeleteExpired(ctx context.Context) error {
	return r.db.WithContext(ctx).Where("expires_at < ?", time.Now()).Delete(&RefreshTokenModel{}).Error
}
