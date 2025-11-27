package repositories

import (
	"crypto/sha256"
	"fmt"
	"time"

	"gorm.io/gorm"
)

// BlacklistedTokenRepository chịu trách nhiệm tương tác với DB cho các access token bị vô hiệu hóa.
type BlacklistedTokenRepository struct {
	db *gorm.DB
}

// NewBlacklistedTokenRepository tạo một instance mới của BlacklistedTokenRepository.
func NewBlacklistedTokenRepository(db *gorm.DB) *BlacklistedTokenRepository {
	return &BlacklistedTokenRepository{
		db: db,
	}
}

// HashToken tạo chuỗi hash SHA-256 cho token để lưu trữ an toàn, tránh lưu token thật.
func (r *BlacklistedTokenRepository) HashToken(token string) string {
	hash := sha256.Sum256([]byte(token))
	return fmt.Sprintf("%x", hash)
}

// AddToBlacklist thêm một access token vào danh sách đen.
// Token sẽ được hash trước khi lưu.
func (r *BlacklistedTokenRepository) AddToBlacklist(token string, expiresAt time.Time) error {
	tokenHash := r.HashToken(token)

	blacklistedToken := &BlacklistedTokenModel{
		TokenHash: tokenHash,
		ExpiresAt: expiresAt,
	}

	return r.db.Create(blacklistedToken).Error
}

// IsBlacklisted kiểm tra xem một access token có nằm trong danh sách đen và còn hiệu lực hay không.
func (r *BlacklistedTokenRepository) IsBlacklisted(token string) (bool, error) {
	tokenHash := r.HashToken(token)

	var count int64
	// Chỉ đếm các token có hash trùng khớp và chưa hết hạn.
	err := r.db.Model(&BlacklistedTokenModel{}).
		Where("token_hash = ? AND expires_at > ?", tokenHash, time.Now()).
		Count(&count).Error

	if err != nil {
		return false, err
	}

	return count > 0, nil
}

// CleanupExpiredTokens xóa các token đã hết hạn khỏi danh sách đen để giữ cho bảng dữ liệu gọn nhẹ.
func (r *BlacklistedTokenRepository) CleanupExpiredTokens() error {
	return r.db.Where("expires_at <= ?", time.Now()).
		Delete(&BlacklistedTokenModel{}).Error
}

// GetExpiredTokensCount đếm số lượng token đã hết hạn (dùng cho mục đích giám sát, theo dõi).
func (r *BlacklistedTokenRepository) GetExpiredTokensCount() (int64, error) {
	var count int64
	err := r.db.Model(&BlacklistedTokenModel{}).
		Where("expires_at <= ?", time.Now()).
		Count(&count).Error
	return count, err
}

// GetActiveTokensCount đếm số lượng token trong danh sách đen nhưng vẫn còn hiệu lực (dùng cho mục đích giám sát).
func (r *BlacklistedTokenRepository) GetActiveTokensCount() (int64, error) {
	var count int64
	err := r.db.Model(&BlacklistedTokenModel{}).
		Where("expires_at > ?", time.Now()).
		Count(&count).Error
	return count, err
}
