package order

import (
	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"

	"myfashion/internal/common/authn"
	authRepos "myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/order/controllers"
	"myfashion/internal/modules/order/repositories"
	"myfashion/internal/modules/order/services"
)

func RegisterRoutes(r chi.Router, db *gorm.DB, jwtSecret string, blacklistRepo *authRepos.BlacklistedTokenRepository, promoService services.PromotionService, notificationSvc services.NotificationService, userStatusChecker authn.UserStatusChecker) {
	// Initialize dependencies
	orderRepo := repositories.NewOrderRepository(db)
	cartRepo := repositories.NewCartRepositoryAdapter(db)
	addressRepo := repositories.NewAddressRepositoryAdapter(db)
	productRepo := repositories.NewProductRepositoryAdapter(db)

	orderSvc := services.NewOrderService(orderRepo, cartRepo, addressRepo, productRepo, promoService, notificationSvc)
	orderCtrl := controllers.NewOrderController(orderSvc)

	// Protected routes (require authentication)
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(jwtSecret, blacklistRepo, userStatusChecker))

		// Customer & Shop routes
		r.Get("/orders", orderCtrl.GetMyOrders)
		r.Get("/orders/{id}", orderCtrl.GetOrderByID)
		r.Post("/orders", orderCtrl.CreateOrder)
		r.Post("/orders/{id}/cancel", orderCtrl.CancelOrder)

		// Shop only routes
		r.Group(func(r chi.Router) {
			r.Use(authn.RequireRole("shop"))

			r.Get("/admin/orders", orderCtrl.AdminListOrders)
			r.Get("/admin/orders/{id}", orderCtrl.AdminGetOrderByID)

			r.Post("/orders/{id}/confirm", orderCtrl.ConfirmOrder)
			r.Put("/orders/{id}/status", orderCtrl.UpdateOrderStatus)
		})
	})
}
