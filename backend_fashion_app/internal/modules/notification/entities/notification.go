package entities

import (
	"time"

	"github.com/google/uuid"
)

type NotificationType string

const (
	TypeOrderCreated     NotificationType = "order.created"
	TypeOrderStatusChanged NotificationType = "order.status_changed"
	TypePromotionNew     NotificationType = "promotion.new"
	TypePromotionExpiring NotificationType = "promotion.expiring"
	TypeAdminManual      NotificationType = "admin.manual"
)

type Notification struct {
	ID        uuid.UUID
	Type      NotificationType
	Title     string
	Body      string
	CreatedBy string
	CreatedAt time.Time
}

type NotificationUser struct {
	ID             uint
	NotificationID uuid.UUID
	UserID         uint
	ReadAt         *time.Time
	CreatedAt      time.Time
}

