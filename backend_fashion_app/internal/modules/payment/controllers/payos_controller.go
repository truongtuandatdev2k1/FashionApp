package controllers

import (
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/payment/api"
	"myfashion/internal/modules/payment/repositories"
	"myfashion/internal/modules/payment/services"
)

type PayOSController struct {
	svc *services.PayOSService
	db  *gorm.DB
}

func NewPayOSController(db *gorm.DB, svc *services.PayOSService) *PayOSController {
	return &PayOSController{db: db, svc: svc}
}

// @Summary Create PayOS payment link
// @Description (Customer) Tạo link thanh toán PayOS cho đơn hàng.
// @Security Bearer
// @Tags Payment
// @Accept json
// @Produce json
// @Param body body api.CreatePayOSPaymentRequest true "Order"
// @Success 200 {object} resp.Envelope{data=api.CreatePayOSPaymentResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /payments/payos/create [post]
func (c *PayOSController) CreatePaymentLink(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}
	if claims.Role != "customer" {
		resp.Error(w, http.StatusForbidden, "customer role required")
		return
	}

	var req api.CreatePayOSPaymentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Load order and ensure ownership
	order, err := c.svcOrderForCustomer(r.Context(), req.OrderID, claims.UID)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	pm, pl, err := c.svc.CreatePaymentLinkForOrder(r.Context(), *order)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	resp.OK(w, api.CreatePayOSPaymentResponse{CheckoutURL: pl.CheckoutUrl, PayosPaymentLinkID: pm.PayosPaymentLinkID, PayosOrderCode: pm.PayosOrderCode})
}

// @Summary Get payment status by order
// @Description (Customer) Lấy trạng thái payment theo order_id.
// @Security Bearer
// @Tags Payment
// @Produce json
// @Param order_id path string true "Order ID (UUID)"
// @Success 200 {object} resp.Envelope{data=api.PaymentStatusResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /payments/{order_id} [get]
func (c *PayOSController) GetPaymentStatus(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}
	if claims.Role != "customer" {
		resp.Error(w, http.StatusForbidden, "customer role required")
		return
	}

	idStr := chi.URLParam(r, "order_id")
	orderID, err := uuid.Parse(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid order_id")
		return
	}

	order, err := c.svcOrderForCustomer(r.Context(), orderID, claims.UID)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "order not found")
		return
	}

	pm, err := c.svc.GetPaymentByOrderID(r.Context(), *order)
	if err != nil {
		resp.Error(w, http.StatusNotFound, "payment not found")
		return
	}

	resp.OK(w, api.PaymentStatusResponse{OrderID: orderID, Status: pm.Status, CheckoutURL: pm.CheckoutURL, PayosPaymentLinkID: pm.PayosPaymentLinkID, PayosOrderCode: pm.PayosOrderCode})
}

// @Summary PayOS webhook
// @Description PayOS gọi webhook để thông báo trạng thái thanh toán.
// @Tags Payment
// @Accept json
// @Produce plain
// @Success 200 {string} string "OK"
// @Failure 400 {string} string "Invalid webhook"
// @Router /payments/payos/webhook [post]
func (c *PayOSController) Webhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}
	log.Printf("payos webhook hit: method=%s, len=%d, body=%s", r.Method, len(body), string(body))

	if len(body) == 0 {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK"))
		return
	}

	var data map[string]any
	if err := json.Unmarshal(body, &data); err != nil {
		log.Printf("payos webhook: failed to unmarshal json: %v", err)
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK"))
		return
	}

	if err := c.svc.HandleWebhook(r.Context(), data); err != nil {
		log.Printf("payos webhook verify failed: %v", err)
		// Return 200 to pass confirm; PayOS will retry real webhooks anyway.
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK"))
		return
	}

	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("OK"))
}

func (c *PayOSController) svcOrderForCustomer(ctx context.Context, orderID uuid.UUID, customerID uint) (*repositories.OrderModel, error) {
	var o repositories.OrderModel
	if err := c.db.WithContext(ctx).Where("id = ? AND customer_id = ?", orderID, customerID).First(&o).Error; err != nil {
		return nil, err
	}
	return &o, nil
}
