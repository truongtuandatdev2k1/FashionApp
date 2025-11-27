package auth

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/auth/controllers"
	"myfashion/internal/modules/auth/repositories"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB) {
	h := controllers.NewAuthController(cfg, db)
	blacklistRepo := repositories.NewBlacklistedTokenRepository(db)

	r.Route("/auth", func(r chi.Router) {
		r.Post("/register", h.Register)
		r.Post("/login", h.Login)
		// Google login removed
		r.With(authn.AuthRequiredWithBlacklist(cfg.JWT_Secret, blacklistRepo)).Get("/me", h.Me)
		r.Post("/refresh", h.Refresh)
		r.With(authn.AuthRequiredWithBlacklist(cfg.JWT_Secret, blacklistRepo)).Post("/logout", h.Logout)
	})
}
