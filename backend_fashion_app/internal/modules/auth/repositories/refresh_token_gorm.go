package repositories

import (
	"context"
	"errors"
	"time"

	"myfashion/internal/modules/auth/entities"

	"gorm.io/gorm"
)

// RefreshTokenRepository chịu trách nhiệm tương tác với DB cho refresh token.
type RefreshTokenRepository struct {
	db *gorm.DB
}

// NewRefreshTokenRepository tạo một instance mới của RefreshTokenRepository.
func NewRefreshTokenRepository(db *gorm.DB) *RefreshTokenRepository {
	return &RefreshTokenRepository{db: db}
}

// Create lưu một refresh token mới vào DB.
func (r *RefreshTokenRepository) Create(ctx context.Context, rt *entities.RefreshToken) error {
	m := ToRefreshTokenModel(rt)
	if err := r.db.WithContext(ctx).Create(m).Error; err != nil {
		return err
	}
	// Cập nhật lại entity với ID và timestamp được tạo tự động.
	*rt = *ToRefreshTokenEntity(m)
	return nil
}

// Save cập nhật một refresh token đã có trong DB.
func (r *RefreshTokenRepository) Save(ctx context.Context, rt *entities.RefreshToken) error {
	m := ToRefreshTokenModel(rt)
	return r.db.WithContext(ctx).Save(m).Error
}

// GetByHash tìm một refresh token bằng chuỗi hash của nó.
func (r *RefreshTokenRepository) GetByHash(ctx context.Context, hash string) (*entities.RefreshToken, error) {
	var m RefreshTokenModel
	if err := r.db.WithContext(ctx).Where("token_hash = ?", hash).First(&m).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil // Trả về nil, nil nếu không tìm thấy.
		}
		return nil, err
	}
	return ToRefreshTokenEntity(&m), nil
}

// RevokeAllByUser thu hồi tất cả các refresh token đang hoạt động của một user.
// Thường dùng cho chức năng "đăng xuất khỏi tất cả thiết bị".
func (r *RefreshTokenRepository) RevokeAllByUser(ctx context.Context, userID uint) error {
	now := time.Now()
	return r.db.WithContext(ctx).
		Model(&RefreshTokenModel{}).
		Where("user_id = ? AND revoked_at IS NULL", userID).
		Update("revoked_at", &now).Error
}

// RevokeDescendants thu hồi một token và tất cả các token con cháu của nó trong chuỗi xoay vòng.
// Đây là biện pháp bảo mật cốt lõi để phát hiện và ngăn chặn tấn công tái sử dụng token.
func (r *RefreshTokenRepository) RevokeDescendants(ctx context.Context, parentTokenHash string) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var tokenToRevoke RefreshTokenModel
		// Tìm token khởi đầu của chuỗi cần thu hồi.
		if err := tx.Where("token_hash = ?", parentTokenHash).First(&tokenToRevoke).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return nil // Không tìm thấy token, không có gì để làm.
			}
			return err
		}

		// Nếu token đã bị thu hồi, chuỗi này đã được xử lý.
		if tokenToRevoke.RevokedAt != nil {
			return nil
		}

		now := time.Now()
		currentTokenHash := tokenToRevoke.TokenHash

		// Lặp qua chuỗi token và thu hồi từng cái một.
		for currentTokenHash != "" {
			result := tx.Model(&RefreshTokenModel{}).
				Where("token_hash = ? AND revoked_at IS NULL", currentTokenHash).
				Update("revoked_at", &now)

			if result.Error != nil {
				return result.Error
			}
			if result.RowsAffected == 0 {
				break // Chuỗi đã bị đứt hoặc đã được thu hồi.
			}

			// Tìm token tiếp theo trong chuỗi.
			var nextToken RefreshTokenModel
			if err := tx.Where("token_hash = ?", currentTokenHash).First(&nextToken).Error; err != nil {
				break // Không tìm thấy token tiếp theo.
			}

			if nextToken.ReplacedByTokenHash == nil {
				currentTokenHash = "" // Hết chuỗi.
			} else {
				currentTokenHash = *nextToken.ReplacedByTokenHash
			}
		}

		return nil
	})
}
