package auth

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/auth/controllers"
	"myfashion/internal/modules/auth/repositories"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *repositories.BlacklistedTokenRepository, userStatusChecker authn.UserStatusChecker) {
	h := controllers.NewAuthController(cfg, db)

	r.Route("/auth", func(r chi.Router) {
		r.Post("/register", h.Register)
		r.Post("/login", h.Login)
		// Google login removed
		r.With(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker)).Get("/me", h.Me)
		r.Post("/refresh", h.Refresh)
		r.With(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker)).Post("/logout", h.Logout)
	})
}
