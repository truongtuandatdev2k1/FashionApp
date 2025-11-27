package profile

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/profile/controllers"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *repositories.BlacklistedTokenRepository) {
	h := controllers.NewProfileController(db)
	r.With(authn.AuthRequiredWithBlacklist(cfg.JWT_Secret, blacklistRepo)).Route("/profiles", func(r chi.Router) {
		r.Get("/me", h.GetMine)
		r.Put("/me", h.UpsertMine)
	})
}
