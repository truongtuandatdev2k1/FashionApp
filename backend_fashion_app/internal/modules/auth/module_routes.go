package auth

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/auth/controllers"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB) {
	h := controllers.NewAuthController(cfg, db)
	r.Route("/auth", func(r chi.Router) {
		r.Post("/register", h.Register)
		r.Post("/login", h.Login)
		r.Post("/google", h.Google)
		r.With(authn.AuthRequired(cfg.JWT_Secret)).Get("/me", h.Me)
		r.Post("/refresh", h.Refresh)
		r.With(authn.AuthRequired(cfg.JWT_Secret)).Post("/logout", h.Logout)
	})
}
