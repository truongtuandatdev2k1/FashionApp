package repositories

import "time"

type UserModel struct {
	ID          uint      `gorm:"primaryKey"`
	Email       string    `gorm:"size:255;uniqueIndex;not null"`
	Password    string    `gorm:"size:255;not null"`
	PhoneNumber string    `gorm:"size:20;uniqueIndex;not null"`
	Role        string    `gorm:"type:enum('shop','customer');index;not null"`
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
}

func (UserModel) TableName() string { return "users" }

type RefreshTokenModel struct {
	ID                  uint       `gorm:"primaryKey"`
	UserID              uint       `gorm:"index;not null"`
	TokenHash           string     `gorm:"size:255;uniqueIndex;not null"`
	ExpiresAt           time.Time  `gorm:"index;not null"`
	RevokedAt           *time.Time `gorm:"index"`
	ReplacedByTokenHash *string    `gorm:"size:255;index"`
	CreatedAt           time.Time
	UpdatedAt           time.Time

	User UserModel `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

func (RefreshTokenModel) TableName() string { return "refresh_tokens" }

// BlacklistedTokenModel định nghĩa schema cho bảng blacklisted_tokens trong DB.
// Bảng này lưu các access token đã bị vô hiệu hóa (ví dụ: khi logout).
type BlacklistedTokenModel struct {
	ID        uint      `gorm:"primaryKey"`
	TokenHash string    `gorm:"type:varchar(255);not null;uniqueIndex"`
	ExpiresAt time.Time `gorm:"not null;index"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

func (BlacklistedTokenModel) TableName() string {
	return "blacklisted_tokens"
}
