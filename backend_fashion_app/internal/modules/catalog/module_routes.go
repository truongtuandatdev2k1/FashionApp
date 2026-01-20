package catalog

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/catalog/controllers"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *repositories.BlacklistedTokenRepository, userStatusChecker authn.UserStatusChecker) {
	h := controllers.NewCatalogController(db)

	// Public routes
	r.Get("/brands", h.ListBrands)
	r.Get("/brands/{id}", h.GetBrand)
	r.Get("/categories", h.ListCategories)
	r.Get("/categories/{id}", h.GetCategory)
	r.Get("/styles", h.ListStyles)
	r.Get("/styles/{id}", h.GetStyle)
	r.Post("/products/list", h.ListProducts)
	// Optional auth for view tracking (public endpoint, but will parse JWT if provided)
	r.With(authn.AuthOptionalWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker)).Get("/products/{id}", h.GetProduct)

	// Authenticated routes (customer + shop)
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker))
		r.Get("/recommendations/for-you", h.GetForYouRecommendations)
		r.Get("/products/{id}/recommendations/related", h.GetRelatedRecommendations)
		r.Post("/wishlist/items", h.AddWishlistItem)
		r.Delete("/wishlist/items/{product_id}", h.RemoveWishlistItem)
		r.Get("/wishlist", h.GetWishlist)
	})

	// Shop-only routes
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker))
		r.Use(authn.RequireRole("shop"))

		// Brand routes
		r.Post("/admin/brands", h.CreateBrand)
		r.Put("/admin/brands/{id}", h.UpdateBrand)
		r.Delete("/admin/brands/{id}", h.DeleteBrand)

		// Category routes for shops
		r.Post("/categories", h.CreateCategory)
		r.Put("/categories/{id}", h.UpdateCategory)
		r.Delete("/categories/{id}", h.DeleteCategory)

		// Style routes for shops
		r.Post("/styles", h.CreateStyle)
		r.Put("/styles/{id}", h.UpdateStyle)
		r.Delete("/styles/{id}", h.DeleteStyle)

		// Product routes for shops
		r.Delete("/products/{id}", h.DeleteProduct)

		// Product creation flow (basic + variants)
		r.Post("/admin/products/basic", h.CreateProductBasic)
		r.Post("/admin/products/{id}/variants", h.UpsertVariantsAndFinalize)

		// Admin product management
		r.Put("/admin/products/{id}/basic", h.AdminUpdateProductBasic)
		r.Get("/admin/products/{id}/variants", h.AdminListVariants)
		r.Put("/admin/product-variants/{variant_id}", h.AdminUpdateVariant)
		r.Put("/admin/product-variants/{variant_id}/stock", h.AdminUpdateVariantStock)

	})
}
