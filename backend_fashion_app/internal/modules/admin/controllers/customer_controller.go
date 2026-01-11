package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"

	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/admin/api"
	"myfashion/internal/modules/admin/services"
)

type CustomerController struct {
	svc *services.CustomerService
}

func NewCustomerController(svc *services.CustomerService) *CustomerController {
	return &CustomerController{svc: svc}
}

// @Summary (Admin) List customers
// @Description (Shop/Admin) Danh sách customer, hỗ trợ search theo email/phone.
// @Security Bearer
// @Tags Admin Customer
// @Produce json
// @Param limit query int false "Limit" default(20)
// @Param offset query int false "Offset" default(0)
// @Param q query string false "Search email/phone"
// @Success 200 {object} resp.Envelope{data=api.CustomerListResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/customers [get]
func (c *CustomerController) List(w http.ResponseWriter, r *http.Request) {
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	if offset < 0 {
		offset = 0
	}
	q := r.URL.Query().Get("q")

	res, err := c.svc.List(r.Context(), q, limit, offset)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}
	resp.OK(w, res)
}

// @Summary (Admin) Customer detail
// @Description (Shop/Admin) Xem chi tiết customer.
// @Security Bearer
// @Tags Admin Customer
// @Produce json
// @Param id path int true "Customer ID"
// @Success 200 {object} resp.Envelope{data=api.CustomerDetailResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/customers/{id} [get]
func (c *CustomerController) Detail(w http.ResponseWriter, r *http.Request) {
	id64, err := strconv.ParseUint(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	res, err := c.svc.Detail(r.Context(), uint(id64))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			resp.Error(w, http.StatusNotFound, "customer not found")
			return
		}
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}
	resp.OK(w, res)
}

// @Summary (Admin) Update customer status
// @Description (Shop/Admin) Khóa/Mở khóa tài khoản customer.
// @Security Bearer
// @Tags Admin Customer
// @Accept json
// @Produce json
// @Param id path int true "Customer ID"
// @Param body body api.UpdateCustomerStatusRequest true "Status"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/customers/{id}/status [put]
func (c *CustomerController) UpdateStatus(w http.ResponseWriter, r *http.Request) {
	id64, err := strconv.ParseUint(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	var req api.UpdateCustomerStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := c.svc.UpdateStatus(r.Context(), uint(id64), req.IsActive); err != nil {
		if err == gorm.ErrRecordNotFound {
			resp.Error(w, http.StatusNotFound, "customer not found")
			return
		}
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}
	resp.OK(w, map[string]bool{"ok": true})
}

// @Summary (Admin) Reset customer password
// @Description (Shop/Admin) Reset password cho customer (admin set password mới).
// @Security Bearer
// @Tags Admin Customer
// @Accept json
// @Produce json
// @Param id path int true "Customer ID"
// @Param body body api.ResetCustomerPasswordRequest true "Password"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/customers/{id}/password [put]
func (c *CustomerController) ResetPassword(w http.ResponseWriter, r *http.Request) {
	id64, err := strconv.ParseUint(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	var req api.ResetCustomerPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := c.svc.ResetPassword(r.Context(), uint(id64), req.NewPassword); err != nil {
		if err == gorm.ErrRecordNotFound {
			resp.Error(w, http.StatusNotFound, "customer not found")
			return
		}
		resp.Error(w, http.StatusInternalServerError, "an unexpected error occurred")
		return
	}
	resp.OK(w, map[string]bool{"ok": true})
}

