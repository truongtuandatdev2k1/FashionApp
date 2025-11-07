package controllers

import (
	"encoding/json"
	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/promotion/api"
	"myfashion/internal/modules/promotion/services"
	"net/http"
)

// @tags Promotion
type PromotionController struct {
	svc *services.PromotionService
}

// NewPromotionController tạo một controller mới
func NewPromotionController(svc *services.PromotionService) *PromotionController {
	return &PromotionController{svc: svc}
}

// --- ADMIN ENDPOINTS ---

// @Summary Create Promotion
// @Description (Admin) Tạo một chương trình khuyến mãi mới
// @Security Bearer
// @Tags Promotion
// @Accept json
// @Produce json
// @Param body body api.CreatePromotionRequest true "Thông tin khuyến mãi"
// @Success 201 {object} resp.Envelope{data=api.PromotionResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Router /admin/promotions [post]
func (c *PromotionController) CreatePromotion(w http.ResponseWriter, r *http.Request) {
	var req api.CreatePromotionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	promotion, err := c.svc.CreatePromotion(r.Context(), &req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error()) // Có thể cần handle lỗi chi tiết hơn
		return
	}

	resp.Created(w, api.ToResponse(promotion))
}

// --- CUSTOMER ENDPOINTS ---

// @Summary Validate Promotions
// @Description (Customer) Kiểm tra và tính toán giá trị của một hoặc nhiều mã khuyến mãi
// @Security Bearer
// @Tags Promotion
// @Accept json
// @Produce json
// @Param body body api.ValidatePromotionRequest true "Thông tin mã và đơn hàng"
// @Success 200 {object} resp.Envelope{data=api.ValidatePromotionResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /promotions/validate [post]
func (c *PromotionController) ValidatePromotions(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "authentication required")
		return
	}

	var req api.ValidatePromotionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	result, err := c.svc.ValidatePromotions(r.Context(), claims.UID, &req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error()) // Có thể cần handle lỗi chi tiết hơn
		return
	}

	resp.OK(w, result)
}
