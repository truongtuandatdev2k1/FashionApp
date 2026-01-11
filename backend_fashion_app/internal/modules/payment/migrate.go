package payment

import (
	"myfashion/internal/modules/payment/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.PaymentModel{},
	)
}

