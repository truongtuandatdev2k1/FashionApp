package services

import (
	"context"
	"fmt"
	"time"

	"myfashion/internal/modules/notification/api"
	"myfashion/internal/modules/notification/entities"

	"github.com/google/uuid"
)

type NotificationService struct {
	repo     NotificationRepository
	userRepo UserRepository
}

func NewNotificationService(repo NotificationRepository, userRepo UserRepository) *NotificationService {
	return &NotificationService{repo: repo, userRepo: userRepo}
}

func (s *NotificationService) createAndAssign(ctx context.Context, n *entities.Notification, userIDs []uint) (int, error) {
	n.ID = uuid.New()
	n.CreatedAt = time.Now()
	if err := s.repo.Create(ctx, n); err != nil {
		return 0, err
	}
	return s.repo.AssignToUsers(ctx, n.ID, userIDs)
}

func (s *NotificationService) NotifyOrderCreated(ctx context.Context, customerID uint, orderNumber string) error {
	notification := &entities.Notification{
		Type:      entities.TypeOrderCreated,
		Title:     "Đơn hàng đã đặt thành công",
		Body:      fmt.Sprintf("Đơn hàng #%s của bạn đã được tiếp nhận và đang chờ xử lý.", orderNumber),
		CreatedBy: "system",
	}
	_, err := s.createAndAssign(ctx, notification, []uint{customerID})
	return err
}

func (s *NotificationService) NotifyOrderStatusChanged(ctx context.Context, customerID uint, orderNumber string, newStatus string) error {
	notification := &entities.Notification{
		Type:      entities.TypeOrderStatusChanged,
		Title:     "Trạng thái đơn hàng đã thay đổi",
		Body:      fmt.Sprintf("Đơn hàng #%s của bạn đã được cập nhật trạng thái: %s.", orderNumber, newStatus),
		CreatedBy: "system",
	}
	_, err := s.createAndAssign(ctx, notification, []uint{customerID})
	return err
}

func (s *NotificationService) NotifyNewPromotion(ctx context.Context, code, description string) error {
	customerIDs, err := s.userRepo.ListUserIDs(ctx, "customer")
	if err != nil {
		return err
	}

	body := fmt.Sprintf("Có mã giảm giá mới: %s.", code)
	if description != "" {
		body = fmt.Sprintf("%s %s", body, description)
	}

	notification := &entities.Notification{
		Type:      entities.TypePromotionNew,
		Title:     "Khuyến mãi mới!",
		Body:      body,
		CreatedBy: "system",
	}
	_, err = s.createAndAssign(ctx, notification, customerIDs)
	return err
}

func (s *NotificationService) NotifyPromotionExpiring(ctx context.Context, code string, endDate time.Time) error {
	customerIDs, err := s.userRepo.ListUserIDs(ctx, "customer")
	if err != nil {
		return err
	}

	notification := &entities.Notification{
		Type:      entities.TypePromotionExpiring,
		Title:     "Mã giảm giá sắp hết hạn",
		Body:      fmt.Sprintf("Mã giảm giá %s sẽ hết hạn vào %s.", code, endDate.Format("02/01/2006")),
		CreatedBy: "system",
	}
	_, err = s.createAndAssign(ctx, notification, customerIDs)
	return err
}

func (s *NotificationService) CreateAdminNotification(ctx context.Context, req api.CreateAdminNotificationRequest) (*entities.Notification, int, error) {
	var userIDs []uint
	var err error

	if req.Target == "all" {
		userIDs, err = s.userRepo.ListUserIDs(ctx, "") // all roles
	} else if req.Target == "user_ids" {
		if len(req.UserIDs) == 0 {
			return nil, 0, entities.ErrEmptyUserIDs
		}
		userIDs = req.UserIDs
	} else {
		return nil, 0, entities.ErrInvalidTarget
	}

	if err != nil {
		return nil, 0, err
	}

	notification := &entities.Notification{
		Type:      entities.TypeAdminManual,
		Title:     req.Title,
		Body:      req.Body,
		CreatedBy: "admin",
	}

	sentCount, err := s.createAndAssign(ctx, notification, userIDs)
	return notification, sentCount, err
}

func (s *NotificationService) ListNotifications(ctx context.Context, userID uint, unreadOnly bool, limit, offset int) ([]NotificationWithRead, int64, error) {
	return s.repo.ListByUser(ctx, userID, unreadOnly, limit, offset)
}

func (s *NotificationService) GetUnreadCount(ctx context.Context, userID uint) (int64, error) {
	return s.repo.UnreadCount(ctx, userID)
}

func (s *NotificationService) MarkAsRead(ctx context.Context, notificationID uuid.UUID, userID uint) (*entities.NotificationUser, error) {
	return s.repo.MarkRead(ctx, notificationID, userID)
}

func (s *NotificationService) MarkAllAsRead(ctx context.Context, userID uint) (int64, error) {
	return s.repo.MarkAllRead(ctx, userID)
}
