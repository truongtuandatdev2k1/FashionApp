package cart

import (
	"myfashion/internal/modules/cart/entities"

	"gorm.io/gorm"
)

// Migrate thực hiện migration cho các bảng của module Cart
func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&entities.Cart{},
		&entities.CartItem{},
	)
}
