package controllers

import (
	"encoding/json"
	"net/http"

	"gorm.io/gorm"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/profile/api"
	"myfashion/internal/modules/profile/entities"
	"myfashion/internal/modules/profile/repositories"
	"myfashion/internal/modules/profile/services"
)

// @tags Profile
type ProfileController struct {
	svc *services.ProfileService
}

func NewProfileController(db *gorm.DB) *ProfileController {
	cRepo := repositories.NewCustomerRepo(db)
	sRepo := repositories.NewShopRepo(db)
	return &ProfileController{svc: services.NewProfileService(cRepo, sRepo)}
}

// GET /profiles/me
// @Summary Get my profile
// @Security Bearer
// @Tags Profile
// @Produce json
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /profiles/me [get]
func (h *ProfileController) GetMine(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	data, err := h.svc.GetMine(r.Context(), claims.Role, claims.UID)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.OK(w, data)
}

// PUT /profiles/me
// @Summary Upsert my profile
// @Description Tạo hoặc cập nhật hồ sơ cho người dùng hiện đang được xác thực. Nội dung yêu cầu phải chứa đối tượng 'khách hàng' hoặc 'cửa hàng', tùy thuộc vào vai trò của người dùng.
// @Security Bearer
// @Tags Profile
// @Accept json
// @Produce json
// @Param body body api.UpsertProfileRequest true "Profile data"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /profiles/me [put]
func (h *ProfileController) UpsertMine(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req api.UpsertProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	switch claims.Role {
	case "customer":
		if req.Customer == nil {
			resp.Error(w, http.StatusBadRequest, "customer data is required")
			return
		}
		if err := validation.Validate(req.Customer); err != nil {
			resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
			return
		}
		err := h.svc.UpsertMine(r.Context(), claims.Role, claims.UID, &entities.CustomerProfile{
			FullName: req.Customer.FullName,
			Age:      req.Customer.Age,
			Gender:   req.Customer.Gender,
			Address:  req.Customer.Address,
		})
		if err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		resp.OK(w, "ok")

	case "shop":
		if req.Shop == nil {
			resp.Error(w, http.StatusBadRequest, "shop data is required")
			return
		}
		if err := validation.Validate(req.Shop); err != nil {
			resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
			return
		}
		err := h.svc.UpsertMine(r.Context(), claims.Role, claims.UID, &entities.ShopProfile{
			ShopName: req.Shop.ShopName,
			Address:  req.Shop.Address,
		})
		if err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		resp.OK(w, "ok")

	default:
		resp.Error(w, http.StatusBadRequest, "unsupported role")
	}
}
