package admin

import (
	"myfashion/internal/common/authn"
	authRepos "myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/admin/controllers"
	"myfashion/internal/modules/admin/repositories"
	"myfashion/internal/modules/admin/services"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, db *gorm.DB, jwtSecret string, blacklistRepo *authRepos.BlacklistedTokenRepository, userStatusChecker authn.UserStatusChecker) {
	repo := repositories.NewCustomerRepository(db)
	svc := services.NewCustomerService(repo)
	ctrl := controllers.NewCustomerController(svc)

	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(jwtSecret, blacklistRepo, userStatusChecker))
		r.Use(authn.RequireRole("shop"))

		r.Get("/admin/customers", ctrl.List)
		r.Get("/admin/customers/{id}", ctrl.Detail)
		r.Put("/admin/customers/{id}/status", ctrl.UpdateStatus)
		r.Put("/admin/customers/{id}/password", ctrl.ResetPassword)
	})
}

