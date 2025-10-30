package cart

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/cart/controllers"
	"myfashion/internal/modules/cart/repositories"
	catalogRepos "myfashion/internal/modules/catalog/repositories"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// RegisterRoutes đăng ký các routes cho module Cart
func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB) {
	// Khởi tạo repositories
	cartRepo := repositories.NewCartGormRepo(db)
	productRepo := catalogRepos.NewProductGormRepo(db)

	// Khởi tạo controller
	h := controllers.NewCartController(db, cartRepo, productRepo)

	// Tất cả routes của Cart đều yêu cầu authentication
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequired(cfg.JWT_Secret))

		// Cart routes
		r.Get("/cart", h.GetCart)                // Lấy giỏ hàng
		r.Delete("/cart", h.ClearCart)           // Xóa toàn bộ giỏ hàng
		r.Get("/cart/summary", h.GetCartSummary) // Tóm tắt giỏ hàng

		// Cart Items routes
		r.Post("/cart/items", h.AddToCart)             // Thêm sản phẩm vào giỏ
		r.Put("/cart/items/{id}", h.UpdateCartItem)    // Cập nhật số lượng
		r.Delete("/cart/items/{id}", h.RemoveCartItem) // Xóa sản phẩm khỏi giỏ
	})
}
