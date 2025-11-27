package repositories

import "myfashion/internal/modules/auth/entities"

// ToUserModel chuyển đổi từ User entity sang UserModel (dùng cho DB).
func ToUserModel(e *entities.User) *UserModel {
	if e == nil {
		return nil
	}
	return &UserModel{
		ID:          e.ID,
		Email:       e.Email,
		Password:    e.Password,
		PhoneNumber: e.PhoneNumber,
		Role:        string(e.Role),
		CreatedAt:   e.CreatedAt,
		UpdatedAt:   e.UpdatedAt,
	}
}

// ToUserEntity chuyển đổi từ UserModel (DB) sang User entity.
func ToUserEntity(m *UserModel) *entities.User {
	if m == nil {
		return nil
	}
	return &entities.User{
		ID:          m.ID,
		Email:       m.Email,
		Password:    m.Password,
		PhoneNumber: m.PhoneNumber,
		Role:        entities.Role(m.Role),
		CreatedAt:   m.CreatedAt,
		UpdatedAt:   m.UpdatedAt,
	}
}

// ToRefreshTokenEntity chuyển đổi từ RefreshTokenModel (DB) sang RefreshToken entity.
func ToRefreshTokenEntity(m *RefreshTokenModel) *entities.RefreshToken {
	if m == nil {
		return nil
	}
	return &entities.RefreshToken{
		ID:                  m.ID,
		UserID:              m.UserID,
		TokenHash:           m.TokenHash,
		ExpiresAt:           m.ExpiresAt,
		RevokedAt:           m.RevokedAt,
		ReplacedByTokenHash: m.ReplacedByTokenHash,
		CreatedAt:           m.CreatedAt,
		UpdatedAt:           m.UpdatedAt,
	}
}

// ToRefreshTokenModel chuyển đổi từ RefreshToken entity sang RefreshTokenModel (dùng cho DB).
func ToRefreshTokenModel(e *entities.RefreshToken) *RefreshTokenModel {
	if e == nil {
		return nil
	}
	return &RefreshTokenModel{
		ID:                  e.ID,
		UserID:              e.UserID,
		TokenHash:           e.TokenHash,
		ExpiresAt:           e.ExpiresAt,
		RevokedAt:           e.RevokedAt,
		ReplacedByTokenHash: e.ReplacedByTokenHash,
		CreatedAt:           e.CreatedAt,
		UpdatedAt:           e.UpdatedAt,
	}
}

// ToBlacklistedTokenEntity chuyển đổi từ BlacklistedTokenModel (DB) sang BlacklistedToken entity.
func ToBlacklistedTokenEntity(model *BlacklistedTokenModel) *entities.BlacklistedToken {
	if model == nil {
		return nil
	}

	return &entities.BlacklistedToken{
		ID:        model.ID,
		TokenHash: model.TokenHash,
		ExpiresAt: model.ExpiresAt,
		CreatedAt: model.CreatedAt,
	}
}

// ToBlacklistedTokenModel chuyển đổi từ BlacklistedToken entity sang BlacklistedTokenModel (dùng cho DB).
func ToBlacklistedTokenModel(entity *entities.BlacklistedToken) *BlacklistedTokenModel {
	if entity == nil {
		return nil
	}

	return &BlacklistedTokenModel{
		ID:        entity.ID,
		TokenHash: entity.TokenHash,
		ExpiresAt: entity.ExpiresAt,
		CreatedAt: entity.CreatedAt,
	}
}
