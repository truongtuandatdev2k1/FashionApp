package entities

import "time"

type RefreshToken struct {
	ID                  uint       `gorm:"primaryKey"`
	UserID              uint       `gorm:"not null;index"`
	TokenHash           string     `gorm:"type:varchar(255);not null;uniqueIndex"`
	ExpiresAt           time.Time  `gorm:"not null"`
	RevokedAt           *time.Time `gorm:"index"`
	ReplacedByTokenHash *string    `gorm:"type:varchar(255);index"`
	CreatedAt           time.Time  `gorm:"autoCreateTime"`
	UpdatedAt           time.Time  `gorm:"autoUpdateTime"`

	// Foreign key relationship
	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// IsActive checks if the token is currently active (not expired and not revoked).
func (rt *RefreshToken) IsActive() bool {
	return rt.RevokedAt == nil && time.Now().Before(rt.ExpiresAt)
}
