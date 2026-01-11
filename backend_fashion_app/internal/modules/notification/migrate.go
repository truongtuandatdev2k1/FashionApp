package notification

import (
	"myfashion/internal/modules/notification/repositories"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&repositories.NotificationModel{},
		&repositories.NotificationUserModel{},
	)
}

