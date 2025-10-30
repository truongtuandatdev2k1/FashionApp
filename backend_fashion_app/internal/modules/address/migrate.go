package address

import (
	"myfashion/internal/modules/address/repositories"

	"gorm.io/gorm"
)

// Migrate performs migration for Address module tables
func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.AddressModel{},
	)
}
