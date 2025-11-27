package cart

import (
	"myfashion/internal/modules/cart/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.CartModel{},
		&repositories.CartItemModel{},
	)
}
