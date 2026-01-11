package payment

import (
	"log"
	"net/http"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	authRepos "myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/payment/controllers"
	"myfashion/internal/modules/payment/repositories"
	"myfashion/internal/modules/payment/services"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *authRepos.BlacklistedTokenRepository, userStatusChecker authn.UserStatusChecker) {
	payRepo := repositories.NewPaymentRepository(db)
	orderRepo := repositories.NewOrderAdapter(db)

	svc, err := services.NewPayOSService(cfg, payRepo, orderRepo)
	if err != nil {
		log.Fatalf("failed to init payos service: %v", err)
	}

	ctrl := controllers.NewPayOSController(db, svc)

	// Public webhook
	r.Get("/payments/payos/webhook", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK"))
	})
	r.Post("/payments/payos/webhook", ctrl.Webhook)

	// Protected routes
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker))

		r.Post("/payments/payos/create", ctrl.CreatePaymentLink)
		r.Get("/payments/{order_id}", ctrl.GetPaymentStatus)
	})
}
