package promotion

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	authRepos "myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/promotion/controllers"
	"myfashion/internal/modules/promotion/repositories"
	"myfashion/internal/modules/promotion/services"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// RegisterRoutes đăng ký tất cả các routes cho module Promotion
// RegisterRoutes đăng ký tất cả các routes cho module Promotion
func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *authRepos.BlacklistedTokenRepository) *services.PromotionService {
	// Khởi tạo các repository adapters cho các module khác
	userRepoAdapter := repositories.NewUserRepoAdapter(db)
	orderRepoAdapter := repositories.NewOrderRepoAdapter(db)

	// Khởi tạo dependencies cho Promotion module
	promoRepo := repositories.NewPromotionRepository(db)
	promoService := services.NewPromotionService(promoRepo, userRepoAdapter, orderRepoAdapter)
	promoController := controllers.NewPromotionController(promoService)

	// Public routes (nếu có)
	r.Post("/promotions/validate", promoController.ValidatePromotions)

	// Admin routes
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklist(cfg.JWT_Secret, blacklistRepo))
		r.Use(authn.RequireRole("shop")) // Chỉ shop/admin mới được truy cập

		r.Post("/admin/promotions", promoController.CreatePromotion)
		// Thêm các routes admin khác ở đây (GET, PUT, DELETE promotions)
	})

	return promoService
}
