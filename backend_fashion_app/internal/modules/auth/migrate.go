package auth

import (
	"myfashion/internal/modules/auth/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.UserModel{},
		&repositories.RefreshTokenModel{},
		&repositories.BlacklistedTokenModel{},
	)
}
