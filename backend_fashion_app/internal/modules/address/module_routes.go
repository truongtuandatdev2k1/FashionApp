package address

import (
	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/modules/address/controllers"
	"myfashion/internal/modules/address/repositories"
	authRepos "myfashion/internal/modules/auth/repositories"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// RegisterRoutes registers all routes for the Address module
// RegisterRoutes registers all routes for the Address module
func RegisterRoutes(r chi.Router, cfg config.Config, db *gorm.DB, blacklistRepo *authRepos.BlacklistedTokenRepository, userStatusChecker authn.UserStatusChecker) {
	// Initialize repositories
	addressRepo := repositories.NewAddressGormRepository(db)

	// Initialize controller
	h := controllers.NewAddressController(db, addressRepo)

	// All Address routes require authentication
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(cfg.JWT_Secret, blacklistRepo, userStatusChecker))

		// Address routes
		r.Get("/addresses", h.GetAllAddresses)                      // Get all addresses
		r.Get("/addresses/default", h.GetDefaultAddress)            // Get default address
		r.Get("/addresses/{id}", h.GetAddress)                      // Get address by ID
		r.Post("/addresses", h.CreateAddress)                       // Create new address
		r.Put("/addresses/{id}", h.UpdateAddress)                   // Update address
		r.Delete("/addresses/{id}", h.DeleteAddress)                // Delete address
		r.Patch("/addresses/{id}/set-default", h.SetDefaultAddress) // Set as default
	})
}
