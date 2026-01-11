package repositories

import (
	"time"

	"github.com/google/uuid"
)

type NotificationModel struct {
	ID        uuid.UUID `gorm:"type:char(36);primaryKey"`
	Type      string    `gorm:"type:varchar(50);index;not null"`
	Title     string    `gorm:"type:varchar(255);not null"`
	Body      string    `gorm:"type:text;not null"`
	CreatedBy string    `gorm:"type:varchar(20);not null"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

func (NotificationModel) TableName() string { return "notifications" }

type NotificationUserModel struct {
	ID             uint      `gorm:"primaryKey"`
	NotificationID uuid.UUID `gorm:"type:char(36);not null;index"`
	UserID         uint      `gorm:"not null;index"`
	ReadAt         *time.Time
	CreatedAt      time.Time `gorm:"autoCreateTime"`

	Notification NotificationModel `gorm:"foreignKey:NotificationID;references:ID;constraint:OnDelete:CASCADE"`
}

func (NotificationUserModel) TableName() string { return "notification_users" }
