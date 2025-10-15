package repositories

import "time"

type UserModel struct {
	ID          uint    `gorm:"primaryKey"`
	Email       string  `gorm:"size:255;uniqueIndex"`
	Password    string  `gorm:"size:255"`
	PhoneNumber string  `gorm:"size:20;uniqueIndex"`
	Role        string  `gorm:"size:20;index"`
	Provider    string  `gorm:"size:20;index"`
	GoogleSub   *string `gorm:"size:64;uniqueIndex"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

func (UserModel) TableName() string { return "users" }

type RefreshTokenModel struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"index"`
	TokenHash string    `gorm:"size:255;index"`
	ExpiresAt time.Time `gorm:"index"`
	Revoked   bool      `gorm:"index"`
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (RefreshTokenModel) TableName() string { return "refresh_tokens" }
