package entities

import "time"

type RefreshToken struct {
	ID        uint
	UserID    uint
	TokenHash string
	ExpiresAt time.Time
	Revoked   bool
	CreatedAt time.Time
	UpdatedAt time.Time
}
