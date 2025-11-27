package promotion

import (
	"myfashion/internal/modules/promotion/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.PromotionModel{},
		&repositories.PromotionUserModel{},
		&repositories.PromotionTierModel{},
	)
}
