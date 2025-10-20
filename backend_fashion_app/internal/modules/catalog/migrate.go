package catalog

import (
	"myfashion/internal/modules/catalog/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.CategoryModel{},
		&repositories.StyleModel{},
		&repositories.ProductModel{},
		&repositories.ProductImageModel{},
	)
}
