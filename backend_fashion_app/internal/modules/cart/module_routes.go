package cart

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	authRepos "myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/cart/controllers"
	"myfashion/internal/modules/cart/repositories"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// RegisterRoutes đăng ký các routes cho module Cart
// RegisterRoutes đăng ký các routes cho module Cart
func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *authRepos.BlacklistedTokenRepository) {
	// Khởi tạo repositories
	cartRepo := repositories.NewCartGormRepo(db)
	productRepo := repositories.NewProductRepositoryAdapter(db)

	// Khởi tạo controller
	h := controllers.NewCartController(db, cartRepo, productRepo)

	// Tất cả routes của Cart đều yêu cầu authentication
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklist(cfg.JWT_Secret, blacklistRepo))

		// Cart routes
		r.Get("/cart", h.GetCart)                // Lấy giỏ hàng
		r.Delete("/cart", h.ClearCart)           // Xóa toàn bộ giỏ hàng
		r.Get("/cart/summary", h.GetCartSummary) // Tóm tắt giỏ hàng

		// Cart Items routes
		r.Post("/cart/items", h.AddToCart)                         // Thêm sản phẩm vào giỏ
		r.Put("/cart/items/{id}", h.UpdateCartItem)                // Cập nhật số lượng
		r.Put("/cart/items/{id}/variant", h.ChangeCartItemVariant) // Đổi màu/size (merge nếu trùng)
		r.Delete("/cart/items/{id}", h.RemoveCartItem)             // Xóa sản phẩm khỏi giỏ
	})
}
