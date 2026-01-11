package repositories

import (
	"myfashion/internal/modules/notification/entities"
)

func toEntity(m *NotificationModel) *entities.Notification {
	if m == nil {
		return nil
	}
	return &entities.Notification{
		ID:        m.ID,
		Type:      entities.NotificationType(m.Type),
		Title:     m.Title,
		Body:      m.Body,
		CreatedBy: m.CreatedBy,
		CreatedAt: m.CreatedAt,
	}
}

