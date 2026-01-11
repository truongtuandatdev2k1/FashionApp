package repositories

import (
	"context"
	"time"

	"myfashion/internal/modules/notification/entities"
	"myfashion/internal/modules/notification/services"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type NotificationRepository struct {
	db *gorm.DB
}

func NewNotificationRepository(db *gorm.DB) *NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) Create(ctx context.Context, n *entities.Notification) error {
	m := &NotificationModel{
		ID:        n.ID,
		Type:      string(n.Type),
		Title:     n.Title,
		Body:      n.Body,
		CreatedBy: n.CreatedBy,
		CreatedAt: n.CreatedAt,
	}
	return r.db.WithContext(ctx).Create(m).Error
}

func (r *NotificationRepository) AssignToUsers(ctx context.Context, notificationID uuid.UUID, userIDs []uint) (int, error) {
	if len(userIDs) == 0 {
		return 0, nil
	}
	rows := make([]NotificationUserModel, 0, len(userIDs))
	for _, uid := range userIDs {
		rows = append(rows, NotificationUserModel{
			NotificationID: notificationID,
			UserID:         uid,
		})
	}
	res := r.db.WithContext(ctx).Create(&rows)
	return int(res.RowsAffected), res.Error
}

func (r *NotificationRepository) ListByUser(ctx context.Context, userID uint, unreadOnly bool, limit, offset int) (items []services.NotificationWithRead, total int64, err error) {
	q := r.db.WithContext(ctx).
		Model(&NotificationUserModel{}).
		Preload("Notification").
		Where("user_id = ?", userID)
	if unreadOnly {
		q = q.Where("read_at IS NULL")
	}
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var rows []NotificationUserModel
	if err := q.Order("id DESC").Limit(limit).Offset(offset).Find(&rows).Error; err != nil {
		return nil, 0, err
	}
	out := make([]services.NotificationWithRead, 0, len(rows))
	for _, row := range rows {
		out = append(out, services.NotificationWithRead{
			Notification: toEntity(&row.Notification),
			ReadAt:       row.ReadAt,
		})
	}
	return out, total, nil
}

func (r *NotificationRepository) UnreadCount(ctx context.Context, userID uint) (int64, error) {
	var cnt int64
	err := r.db.WithContext(ctx).
		Model(&NotificationUserModel{}).
		Where("user_id = ? AND read_at IS NULL", userID).
		Count(&cnt).Error
	return cnt, err
}

func (r *NotificationRepository) MarkRead(ctx context.Context, notificationID uuid.UUID, userID uint) (*entities.NotificationUser, error) {
	var nu NotificationUserModel
	err := r.db.WithContext(ctx).
		Where("notification_id = ? AND user_id = ?", notificationID, userID).
		First(&nu).Error
	if err != nil {
		return nil, err
	}

	if nu.ReadAt == nil {
		now := r.db.NowFunc()
		nu.ReadAt = &now
		if err := r.db.WithContext(ctx).Model(&NotificationUserModel{}).
			Where("id = ?", nu.ID).
			Update("read_at", now).Error; err != nil {
			return nil, err
		}
	}

	return &entities.NotificationUser{
		ID:             nu.ID,
		NotificationID: nu.NotificationID,
		UserID:         nu.UserID,
		ReadAt:         nu.ReadAt,
		CreatedAt:      nu.CreatedAt,
	}, nil
}

func (r *NotificationRepository) MarkAllRead(ctx context.Context, userID uint) (int64, error) {
	now := time.Now()
	res := r.db.WithContext(ctx).Model(&NotificationUserModel{}).
		Where("user_id = ? AND read_at IS NULL", userID).
		Update("read_at", now)
	return res.RowsAffected, res.Error
}
