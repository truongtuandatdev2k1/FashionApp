package controllers

import (
	"encoding/json"
	"net/http"

	"gorm.io/gorm"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
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
// @Security Bearer
// @Tags Profile
// @Accept json
// @Produce json
// @Param customer body api.CustomerUpsert false "Nếu role=customer"
// @Param shop body api.ShopUpsert     false "Nếu role=shop"
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

	switch claims.Role {
	case "customer":
		var req api.CustomerUpsert
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			resp.Error(w, http.StatusBadRequest, "invalid body")
			return
		}
		err := h.svc.UpsertMine(r.Context(), claims.Role, claims.UID, &entities.CustomerProfile{
			FullName:  req.FullName,
			Gender:    req.Gender,
			Birthdate: req.Birthdate,
			HeightCM:  req.HeightCM,
			WeightKG:  req.WeightKG,
		})
		if err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		resp.OK(w, "ok")

	case "shop":
		var req api.ShopUpsert
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			resp.Error(w, http.StatusBadRequest, "invalid body")
			return
		}
		err := h.svc.UpsertMine(r.Context(), claims.Role, claims.UID, &entities.ShopProfile{
			ShopName: req.ShopName,
			Address:  req.Address,
			Phone:    req.Phone,
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
