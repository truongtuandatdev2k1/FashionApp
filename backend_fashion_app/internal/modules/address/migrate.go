package address

import (
	"myfashion/internal/modules/address/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(&repositories.AddressModel{})
}
