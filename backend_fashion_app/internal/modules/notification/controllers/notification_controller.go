package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/notification/api"
	"myfashion/internal/modules/notification/services"
)

type NotificationController struct {
	svc *services.NotificationService
}

func NewNotificationController(svc *services.NotificationService) *NotificationController {
	return &NotificationController{svc: svc}
}

func (c *NotificationController) getUserID(r *http.Request) (uint, bool) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		return 0, false
	}
	return claims.UID, true
}

// @Summary List my notifications
// @Description Lấy danh sách thông báo của tôi (in-app). Có thể lọc chưa đọc.
// @Security Bearer
// @Tags Notification
// @Produce json
// @Param limit query int false "Limit" default(20)
// @Param offset query int false "Offset" default(0)
// @Param unread query bool false "Unread only"
// @Success 200 {object} resp.Envelope{data=api.NotificationListResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /notifications [get]
func (c *NotificationController) ListMyNotifications(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	if offset < 0 {
		offset = 0
	}
	unreadOnly := r.URL.Query().Get("unread") == "1" || r.URL.Query().Get("unread") == "true"

	items, total, err := c.svc.ListNotifications(r.Context(), userID, unreadOnly, limit, offset)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}

	out := make([]api.NotificationResponse, 0, len(items))
	for _, it := range items {
		out = append(out, api.NotificationResponse{
			ID:        it.Notification.ID,
			Type:      it.Notification.Type,
			Title:     it.Notification.Title,
			Body:      it.Notification.Body,
			ReadAt:    it.ReadAt,
			CreatedAt: it.Notification.CreatedAt,
		})
	}

	resp.OK(w, api.NotificationListResponse{Items: out, Total: total, Limit: limit, Offset: offset})
}

// @Summary Unread notifications count
// @Description Lấy số lượng thông báo chưa đọc của tôi.
// @Security Bearer
// @Tags Notification
// @Produce json
// @Success 200 {object} resp.Envelope{data=api.UnreadCountResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /notifications/unread-count [get]
func (c *NotificationController) UnreadCount(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	cnt, err := c.svc.GetUnreadCount(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}

	resp.OK(w, api.UnreadCountResponse{UnreadCount: cnt})
}

// @Summary Mark a notification as read
// @Description Đánh dấu 1 thông báo là đã đọc (app mobile gọi khi user bấm vào thông báo).
// @Security Bearer
// @Tags Notification
// @Produce json
// @Param id path string true "Notification ID (UUID)"
// @Success 200 {object} resp.Envelope{data=api.MarkReadResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /notifications/{id}/read [put]
func (c *NotificationController) MarkRead(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	idStr := chi.URLParam(r, "id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id format")
		return
	}

	nu, err := c.svc.MarkAsRead(r.Context(), id, userID)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "notification not found")
		return
	}

	resp.OK(w, api.MarkReadResponse{ReadAt: *nu.ReadAt})
}

// @Summary Mark all notifications as read
// @Description Đánh dấu tất cả thông báo của tôi là đã đọc.
// @Security Bearer
// @Tags Notification
// @Produce json
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /notifications/read-all [put]
func (c *NotificationController) MarkAllRead(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	_, err := c.svc.MarkAllAsRead(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}

	resp.OK(w, map[string]bool{"ok": true})
}

// @Summary (Admin) Create manual notification
// @Description (Shop/Admin) Tạo thông báo thủ công. Target chỉ hỗ trợ `all` hoặc `user_ids`.
// @Security Bearer
// @Tags Notification
// @Accept json
// @Produce json
// @Param body body api.CreateAdminNotificationRequest true "Notification"
// @Success 201 {object} resp.Envelope{data=api.CreateAdminNotificationResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/notifications [post]
func (c *NotificationController) AdminCreate(w http.ResponseWriter, r *http.Request) {
	var req api.CreateAdminNotificationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	n, sentTo, err := c.svc.CreateAdminNotification(r.Context(), req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	resp.Created(w, api.CreateAdminNotificationResponse{ID: n.ID, CreatedAt: n.CreatedAt, SentTo: sentTo})
}
