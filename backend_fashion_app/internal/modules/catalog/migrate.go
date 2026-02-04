package catalog

import (
	"myfashion/internal/modules/catalog/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	if err := db.AutoMigrate(
		&repositories.CategoryModel{},
		&repositories.StyleModel{},
		&repositories.BrandModel{},
		&repositories.ProductModel{},
		&repositories.ProductVariantModel{},
		&repositories.ProductColorModel{},
		&repositories.ProductColorImageModel{},
		&repositories.ProductStatsModel{},
		&repositories.ProductViewModel{},
		&repositories.WishlistItemModel{},
		&repositories.ProductSimilarityModel{},
	); err != nil {
		return err
	}
	// Drop legacy tables if they still exist
	if db.Migrator().HasTable("product_images") {
		if err := db.Migrator().DropTable("product_images"); err != nil {
			return err
		}
	}
	if db.Migrator().HasTable("colors") {
		if err := db.Migrator().DropTable("colors"); err != nil {
			return err
		}
	}
	if db.Migrator().HasTable("product_recommendations") {
		if err := db.Migrator().DropTable("product_recommendations"); err != nil {
			return err
		}
	}
	return nil
}
