package promotion

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/promotion/controllers"
	"myfashion/internal/modules/promotion/repositories"
	"myfashion/internal/modules/promotion/services"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// RegisterRoutes đăng ký tất cả các routes cho module Promotion
func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB) {
	// Khởi tạo các repository adapters cho các module khác (nếu cần)
	// Ví dụ: userRepoAdapter := repositories.NewUserRepoAdapter(db)

	// Khởi tạo dependencies cho Promotion module
	promoRepo := repositories.NewPromotionRepository(db)
	// userRepo := ...
	// orderRepo := ...
	promoService := services.NewPromotionService(promoRepo, nil, nil) // Tạm thời để nil, sẽ cập nhật sau
	promoController := controllers.NewPromotionController(promoService)

	// Public routes (nếu có)
	r.Post("/promotions/validate", promoController.ValidatePromotions)

	// Admin routes
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequired(cfg.JWT_Secret))
		r.Use(authn.RequireRole("shop")) // Chỉ shop/admin mới được truy cập

		r.Post("/admin/promotions", promoController.CreatePromotion)
		// Thêm các routes admin khác ở đây (GET, PUT, DELETE promotions)
	})
}
