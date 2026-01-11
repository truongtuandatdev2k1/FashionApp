package api

import (
	"time"

	"github.com/google/uuid"
	"myfashion/internal/modules/notification/entities"
)

type NotificationResponse struct {
	ID        uuid.UUID                 `json:"id"`
	Type      entities.NotificationType `json:"type"`
	Title     string                    `json:"title"`
	Body      string                    `json:"body"`
	ReadAt    *time.Time                `json:"read_at"`
	CreatedAt time.Time                 `json:"created_at"`
}

type NotificationListResponse struct {
	Items  []NotificationResponse `json:"items"`
	Total  int64                  `json:"total"`
	Limit  int                    `json:"limit"`
	Offset int                    `json:"offset"`
}

type UnreadCountResponse struct {
	UnreadCount int64 `json:"unread_count"`
}

type MarkReadResponse struct {
	ReadAt time.Time `json:"read_at"`
}

type CreateAdminNotificationRequest struct {
	Title   string `json:"title" validate:"required"`
	Body    string `json:"body" validate:"required"`
	Target  string `json:"target" validate:"required,oneof=all user_ids"`
	UserIDs []uint `json:"user_ids"`
}

type CreateAdminNotificationResponse struct {
	ID        uuid.UUID  `json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	SentTo    int        `json:"sent_to"`
}

