package controllers

import (
	"encoding/json"
	"errors"
	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/cart/api"
	"myfashion/internal/modules/cart/services"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// @tags Cart
type CartController struct {
	svc *services.CartService
}

// NewCartController tạo một CartController mới
func NewCartController(db *gorm.DB, cartRepo services.CartRepository, productRepo services.ProductRepository) *CartController {
	svc := services.NewCartService(cartRepo, productRepo)
	return &CartController{svc: svc}
}

// --- Helpers ---

func (c *CartController) getUserID(r *http.Request) (uint, bool) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		return 0, false
	}
	return claims.UID, true
}

func (c *CartController) parseID(w http.ResponseWriter, r *http.Request, key string) (uint, bool) {
	idStr := chi.URLParam(r, key)
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id")
		return 0, false
	}
	return uint(id), true
}

func (c *CartController) handleServiceError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, services.ErrProductNotFound), errors.Is(err, services.ErrCartItemNotFound):
		resp.Error(w, http.StatusNotFound, err.Error())
	case errors.Is(err, services.ErrInsufficientStock), errors.Is(err, services.ErrInvalidQuantity):
		resp.Error(w, http.StatusBadRequest, err.Error())
	case errors.Is(err, services.ErrUnauthorized):
		resp.Error(w, http.StatusForbidden, err.Error())
	default:
		resp.Error(w, http.StatusInternalServerError, "một lỗi không mong muốn đã xảy ra")
	}
}

// --- Handlers ---

// @Summary Get Cart
// @Description Lấy thông tin giỏ hàng của người dùng hiện tại
// @Security Bearer
// @Tags Cart
// @Produce json
// @Success 200 {object} resp.Envelope{data=api.CartResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /cart [get]
func (c *CartController) GetCart(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "yêu cầu đăng nhập")
		return
	}

	cart, err := c.svc.GetCart(r.Context(), userID)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, cart)
}

// @Summary Add Item to Cart
// @Description Thêm một sản phẩm vào giỏ hàng
// @Security Bearer
// @Tags Cart
// @Accept json
// @Produce json
// @Param body body api.AddToCartRequest true "Thông tin sản phẩm cần thêm"
// @Success 201 {object} resp.Envelope{data=api.CartItemResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /cart/items [post]
func (c *CartController) AddToCart(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "yêu cầu đăng nhập")
		return
	}

	var req api.AddToCartRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	cartItem, err := c.svc.AddToCart(r.Context(), userID, req)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.Created(w, cartItem)
}

// @Summary Update Cart Item
// @Description Cập nhật số lượng của một sản phẩm trong giỏ hàng
// @Security Bearer
// @Tags Cart
// @Accept json
// @Produce json
// @Param id path int true "ID của Cart Item"
// @Param body body api.UpdateCartItemRequest true "Số lượng mới"
// @Success 200 {object} resp.Envelope{data=api.CartItemResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /cart/items/{id} [put]
func (c *CartController) UpdateCartItem(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "yêu cầu đăng nhập")
		return
	}

	itemID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	var req api.UpdateCartItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	updatedItem, err := c.svc.UpdateCartItem(r.Context(), userID, itemID, req)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, updatedItem)
}

// @Summary Remove Cart Item
// @Description Xóa một sản phẩm khỏi giỏ hàng
// @Security Bearer
// @Tags Cart
// @Produce json
// @Param id path int true "ID của Cart Item"
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Router /cart/items/{id} [delete]
func (c *CartController) RemoveCartItem(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "yêu cầu đăng nhập")
		return
	}

	itemID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	if err := c.svc.RemoveCartItem(r.Context(), userID, itemID); err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, "sản phẩm đã được xóa khỏi giỏ hàng")
}

// @Summary Clear Cart
// @Description Xóa toàn bộ sản phẩm trong giỏ hàng
// @Security Bearer
// @Tags Cart
// @Produce json
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /cart [delete]
func (c *CartController) ClearCart(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "yêu cầu đăng nhập")
		return
	}

	if err := c.svc.ClearCart(r.Context(), userID); err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, "giỏ hàng đã được xóa sạch")
}

// @Summary Get Cart Summary
// @Description Lấy tóm tắt giỏ hàng để chuẩn bị thanh toán
// @Security Bearer
// @Tags Cart
// @Produce json
// @Success 200 {object} resp.Envelope{data=api.CartSummaryResponse}
// @Failure 401 {object} resp.Envelope
// @Router /cart/summary [get]
func (c *CartController) GetCartSummary(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "yêu cầu đăng nhập")
		return
	}

	summary, err := c.svc.GetCartSummary(r.Context(), userID)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, summary)
}
