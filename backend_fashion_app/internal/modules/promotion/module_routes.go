package promotion

import (
	"context"
	"time"

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
func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *authRepos.BlacklistedTokenRepository, notificationSvc services.NotificationService, userStatusChecker authn.UserStatusChecker) *services.PromotionService {
	// Khởi tạo các repository adapters cho các module khác
	userRepoAdapter := repositories.NewUserRepoAdapter(db)
	orderRepoAdapter := repositories.NewOrderRepoAdapter(db)

	// Khởi tạo dependencies cho Promotion module
	promoRepo := repositories.NewPromotionRepository(db)
	promoService := services.NewPromotionService(promoRepo, userRepoAdapter, orderRepoAdapter, notificationSvc)
	promoController := controllers.NewPromotionController(promoService)

	// Start expiring-promotion scheduler: expiring within <= 3 days, run every 6 hours
	scheduler := services.NewExpiringPromotionScheduler(promoRepo, notificationSvc, 72*time.Hour, 6*time.Hour)
	go scheduler.Start(context.Background())

	// Public routes (nếu có)
	r.Post("/promotions/validate", promoController.ValidatePromotions)

	// Admin routes
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker))
		r.Use(authn.RequireRole("shop")) // Chỉ shop/admin mới được truy cập

		r.Post("/admin/promotions", promoController.CreatePromotion)
		// Thêm các routes admin khác ở đây (GET, PUT, DELETE promotions)
	})

	return promoService
}
