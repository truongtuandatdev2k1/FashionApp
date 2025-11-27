package entities

import "time"

type BlacklistedToken struct {
	ID        uint      `gorm:"primaryKey"`
	TokenHash string    `gorm:"type:varchar(255);not null;uniqueIndex"`
	ExpiresAt time.Time `gorm:"not null;index"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

func (BlacklistedToken) TableName() string {
	return "blacklisted_tokens"
}
