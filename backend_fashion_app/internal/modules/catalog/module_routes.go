package catalog

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/catalog/controllers"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB) {
	h := controllers.NewCatalogController(db)

	// Public routes
	r.Get("/categories", h.ListCategories)
	r.Get("/categories/{id}", h.GetCategory)
	r.Get("/styles", h.ListStyles)
	r.Get("/styles/{id}", h.GetStyle)
	r.Post("/products/list", h.ListProducts)
	r.Get("/products/{id}", h.GetProduct)

	// Shop-only routes
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequired(cfg.JWT_Secret))

		// Category routes for shops
		r.Post("/categories", h.CreateCategory)
		r.Put("/categories/{id}", h.UpdateCategory)
		r.Delete("/categories/{id}", h.DeleteCategory)

		// Style routes for shops
		r.Post("/styles", h.CreateStyle)
		r.Put("/styles/{id}", h.UpdateStyle)
		r.Delete("/styles/{id}", h.DeleteStyle)

		// Product routes for shops
		r.Post("/products", h.CreateProduct)
		r.Put("/products/{id}", h.UpdateProduct)
		r.Delete("/products/{id}", h.DeleteProduct)
	})
}
