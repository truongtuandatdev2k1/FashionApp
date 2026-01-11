package controllers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"myfashion/internal/common/resp"
	"myfashion/internal/modules/order/api"
	"myfashion/internal/modules/order/entities"
	"myfashion/internal/modules/order/services"
)

// @Summary (Admin) List orders
// @Description (Shop/Admin) Danh sách tất cả đơn hàng, filter theo status/date/customer.
// @Security Bearer
// @Tags Order
// @Produce json
// @Param limit query int false "Limit" default(20)
// @Param offset query int false "Offset" default(0)
// @Param status query string false "Order status" Enums(pending, confirmed, processing, shipping, delivered, cancelled, returned)
// @Param customer_id query int false "Customer ID"
// @Param from query string false "From date (RFC3339)"
// @Param to query string false "To date (RFC3339)"
// @Success 200 {object} resp.Envelope{data=api.AdminOrderListResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/orders [get]
func (c *OrderController) AdminListOrders(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "shop role required")
		return
	}

	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	if offset < 0 {
		offset = 0
	}

	var filter services.AdminOrderFilter
	if v := r.URL.Query().Get("status"); v != "" {
		st := entities.OrderStatus(v)
		filter.Status = &st
	}
	if v := r.URL.Query().Get("customer_id"); v != "" {
		cid, err := strconv.ParseUint(v, 10, 64)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, "invalid customer_id")
			return
		}
		cidu := uint(cid)
		filter.CustomerID = &cidu
	}
	if v := r.URL.Query().Get("from"); v != "" {
		t, err := time.Parse(time.RFC3339, v)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, "invalid from")
			return
		}
		filter.FromDate = &t
	}
	if v := r.URL.Query().Get("to"); v != "" {
		t, err := time.Parse(time.RFC3339, v)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, "invalid to")
			return
		}
		filter.ToDate = &t
	}

	orders, total, err := c.svc.AdminListOrders(r.Context(), filter, limit, offset)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}

	items := make([]api.AdminOrderSummary, 0, len(orders))
	for _, o := range orders {
		customerName := ""
		if o.ShippingName != "" {
			customerName = o.ShippingName
		}

		items = append(items, api.AdminOrderSummary{
			ID:            o.ID,
			OrderNumber:   o.OrderNumber,
			Status:        o.Status,
			PaymentStatus: string(o.PaymentStatus),
			CustomerName:  customerName,
			ShippingPhone: o.ShippingPhone,
			TotalAmount:   o.TotalAmount,
			CreatedAt:     o.CreatedAt,
		})
	}

	resp.OK(w, api.AdminOrderListResponse{Items: items, Total: total, Limit: limit, Offset: offset})
}

// @Summary (Admin) Get order by ID
// @Description (Shop/Admin) Xem chi tiết đơn hàng theo ID.
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
// @Router /admin/orders/{id} [get]
func (c *OrderController) AdminGetOrderByID(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "shop role required")
		return
	}

	idStr := chi.URLParam(r, "id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id format")
		return
	}

	order, err := c.svc.AdminGetOrderByID(r.Context(), id)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToOrderResponse(order))
}
