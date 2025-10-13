package profile

import (
	"myfashion/internal/modules/profile/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(&repositories.CustomerProfileModel{}, &repositories.ShopProfileModel{})
}
