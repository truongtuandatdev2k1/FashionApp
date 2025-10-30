package order

import (
	"myfashion/internal/modules/order/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.OrderModel{},
		&repositories.OrderItemModel{},
	)
}
