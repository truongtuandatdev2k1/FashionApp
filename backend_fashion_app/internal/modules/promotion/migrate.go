package promotion

import (
	"myfashion/internal/modules/promotion/repositories"

	"gorm.io/gorm"
)

// Migrate thực hiện migration cho các bảng của module Promotion
func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.PromotionModel{},
		&repositories.PromotionUserModel{},
		&repositories.PromotionTierModel{},
	)
}
