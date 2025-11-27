package controllers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/order/api"
	"myfashion/internal/modules/order/entities"
	"myfashion/internal/modules/order/services"
)

// @tags Order
type OrderController struct {
	svc *services.OrderService
}

func NewOrderController(svc *services.OrderService) *OrderController {
	return &OrderController{svc: svc}
}

// --- Helpers ---

func (c *OrderController) getUserID(r *http.Request) (uint, bool) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		return 0, false
	}
	return claims.UID, true
}

func (c *OrderController) isShop(r *http.Request) bool {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		return false
	}
	return claims.Role == "shop"
}

func (c *OrderController) parseUUID(w http.ResponseWriter, r *http.Request, key string) (uuid.UUID, bool) {
	idStr := chi.URLParam(r, key)
	id, err := uuid.Parse(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id format")
		return uuid.Nil, false
	}
	return id, true
}

func (c *OrderController) handleServiceError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, entities.ErrOrderNotFound):
		resp.Error(w, http.StatusNotFound, err.Error())
	case errors.Is(err, entities.ErrEmptyCart),
		errors.Is(err, entities.ErrInvalidShippingAddress),
		errors.Is(err, entities.ErrOrderCannotBeCancelled),
		errors.Is(err, entities.ErrOrderCannotBeConfirmed),
		errors.Is(err, entities.ErrInvalidStatusTransition):
		resp.Error(w, http.StatusBadRequest, err.Error())
	case errors.Is(err, entities.ErrUnauthorizedAccess):
		resp.Error(w, http.StatusForbidden, err.Error())
	default:
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
	}
}

// --- Handlers ---

// @Summary Create Order
// @Description Tạo đơn hàng mới từ giỏ hàng (customer), các loại thanh toán: cod, bank_transfer, e_wallet
// @Security Bearer
// @Tags Order
// @Accept json
// @Produce json
// @Param request body api.CreateOrderRequest true "Order info"
// @Success 201 {object} resp.Envelope{data=api.OrderResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /orders [post]
func (c *OrderController) CreateOrder(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	var req api.CreateOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Convert payment method string to entity type
	paymentMethod := entities.PaymentMethod(req.PaymentMethod)

	// Create order from selected cart items
	order, err := c.svc.CreateOrderFromCart(
		r.Context(),
		userID,
		req.AddressID,
		req.CartItemIDs,
		paymentMethod,
		req.Note,
		req.PromotionCodes,
	)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.JSON(w, http.StatusCreated, api.ToOrderResponse(order))
}

// @Summary Get Order by ID
// @Description Lấy thông tin đơn hàng theo ID
// @Security Bearer
// @Tags Order
// @Produce json
// @Param id path string true "Order ID (UUID)"
// @Success 200 {object} resp.Envelope{data=api.OrderResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /orders/{id} [get]
func (c *OrderController) GetOrderByID(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	orderID, ok := c.parseUUID(w, r, "id")
	if !ok {
		return
	}

	order, err := c.svc.GetOrderByID(r.Context(), orderID, userID, c.isShop(r))
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToOrderResponse(order))
}

// @Summary Get My Orders
// @Description Lấy danh sách đơn hàng của tôi (customer hoặc shop)
// @Security Bearer
// @Tags Order
// @Produce json
// @Param limit query int false "Limit" default(20)
// @Param offset query int false "Offset" default(0)
// @Param status query string false "Filter by status" Enums(pending, confirmed, processing, shipping, delivered, cancelled, returned)
// @Success 200 {object} resp.Envelope{data=api.OrderListResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /orders [get]
func (c *OrderController) GetMyOrders(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	// Parse pagination
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	if offset < 0 {
		offset = 0
	}

	// Parse status filter
	statusStr := r.URL.Query().Get("status")

	var orders []*entities.Order
	var total int64
	var err error

	if c.isShop(r) {
		// Shop: get orders for this shop
		orders, total, err = c.svc.GetShopOrders(r.Context(), userID, limit, offset)
	} else {
		// Customer: get orders for this customer
		if statusStr != "" {
			status := entities.OrderStatus(statusStr)
			orders, total, err = c.svc.GetCustomerOrdersByStatus(r.Context(), userID, status, limit, offset)
		} else {
			orders, total, err = c.svc.GetCustomerOrders(r.Context(), userID, limit, offset)
		}
	}

	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToOrderListResponse(orders, total, limit, offset))
}

// @Summary Confirm Order
// @Description Xác nhận đơn hàng (shop only)
// @Security Bearer
// @Tags Order
// @Produce json
// @Param id path string true "Order ID (UUID)"
// @Success 200 {object} resp.Envelope{data=api.OrderResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /orders/{id}/confirm [post]
func (c *OrderController) ConfirmOrder(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "shop role required")
		return
	}

	orderID, ok := c.parseUUID(w, r, "id")
	if !ok {
		return
	}

	order, err := c.svc.ConfirmOrder(r.Context(), orderID, userID)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToOrderResponse(order))
}

// @Summary Update Order Status
// @Description Cập nhật trạng thái đơn hàng (shop only)
// @Security Bearer
// @Tags Order
// @Accept json
// @Produce json
// @Param id path string true "Order ID (UUID)"
// @Param request body api.UpdateOrderStatusRequest true "New status"
// @Success 200 {object} resp.Envelope{data=api.OrderResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /orders/{id}/status [put]
func (c *OrderController) UpdateOrderStatus(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "shop role required")
		return
	}

	orderID, ok := c.parseUUID(w, r, "id")
	if !ok {
		return
	}

	var req api.UpdateOrderStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	order, err := c.svc.UpdateOrderStatus(r.Context(), orderID, userID, entities.OrderStatus(req.Status))
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToOrderResponse(order))
}

// @Summary Cancel Order
// @Description Hủy đơn hàng (customer hoặc shop)
// @Security Bearer
// @Tags Order
// @Accept json
// @Produce json
// @Param id path string true "Order ID (UUID)"
// @Param request body api.CancelOrderRequest true "Cancel reason"
// @Success 200 {object} resp.Envelope{data=api.OrderResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /orders/{id}/cancel [post]
func (c *OrderController) CancelOrder(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	orderID, ok := c.parseUUID(w, r, "id")
	if !ok {
		return
	}

	var req api.CancelOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	order, err := c.svc.CancelOrder(r.Context(), orderID, userID, req.Reason, c.isShop(r))
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToOrderResponse(order))
}
