package notification

import (
	"myfashion/internal/common/authn"
	authRepos "myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/notification/controllers"
	"myfashion/internal/modules/notification/repositories"
	"myfashion/internal/modules/notification/services"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

func RegisterRoutes(r chi.Router, db *gorm.DB, jwtSecret string, blacklistRepo *authRepos.BlacklistedTokenRepository, userStatusChecker authn.UserStatusChecker) *services.NotificationService {
	// Initialize repositories
	notifRepo := repositories.NewNotificationRepository(db)
	userRepo := repositories.NewUserRepositoryAdapter(db)

	// Initialize service
	svc := services.NewNotificationService(notifRepo, userRepo)

	// Initialize controller
	ctrl := controllers.NewNotificationController(svc)

	// Public routes (none)

	// Protected routes (require auth)
	r.Group(func(r chi.Router) {
		r.Use(authn.AuthRequiredWithBlacklistAndUserStatus(jwtSecret, blacklistRepo, userStatusChecker))

		r.Get("/notifications", ctrl.ListMyNotifications)
		r.Get("/notifications/unread-count", ctrl.UnreadCount)
		r.Put("/notifications/{id}/read", ctrl.MarkRead)
		r.Put("/notifications/read-all", ctrl.MarkAllRead)

		// Admin routes (shop role)
		r.Group(func(r chi.Router) {
			r.Use(authn.RequireRole("shop"))
			r.Post("/admin/notifications", ctrl.AdminCreate)
		})
	})

	return svc
}
