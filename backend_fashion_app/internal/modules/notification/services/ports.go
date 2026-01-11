package services

import (
	"context"
	"time"

	"myfashion/internal/modules/notification/entities"

	"github.com/google/uuid"
)

type NotificationRepository interface {
	Create(ctx context.Context, n *entities.Notification) error
	AssignToUsers(ctx context.Context, notificationID uuid.UUID, userIDs []uint) (int, error)
	ListByUser(ctx context.Context, userID uint, unreadOnly bool, limit, offset int) (items []NotificationWithRead, total int64, err error)
	UnreadCount(ctx context.Context, userID uint) (int64, error)
	MarkRead(ctx context.Context, notificationID uuid.UUID, userID uint) (*entities.NotificationUser, error)
	MarkAllRead(ctx context.Context, userID uint) (int64, error)
}

type NotificationWithRead struct {
	Notification *entities.Notification
	ReadAt       *time.Time
}

type UserRepository interface {
	ListUserIDs(ctx context.Context, role string) ([]uint, error)
}
