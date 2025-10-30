package controllers

import (
	"encoding/json"
	"errors"
	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/address/api"
	"myfashion/internal/modules/address/entities"
	"myfashion/internal/modules/address/services"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

// @tags Address
type AddressController struct {
	svc *services.AddressService
}

// NewAddressController creates a new AddressController
func NewAddressController(db *gorm.DB, addressRepo services.AddressRepository) *AddressController {
	svc := services.NewAddressService(addressRepo)
	return &AddressController{svc: svc}
}

// --- Helpers ---

func (c *AddressController) getUserID(r *http.Request) (uint, bool) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		return 0, false
	}
	return claims.UID, true
}

func (c *AddressController) parseID(w http.ResponseWriter, r *http.Request, key string) (uint, bool) {
	idStr := chi.URLParam(r, key)
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid id")
		return 0, false
	}
	return uint(id), true
}

func (c *AddressController) handleServiceError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, entities.ErrAddressNotFound):
		resp.Error(w, http.StatusNotFound, "address not found")
	case errors.Is(err, entities.ErrUnauthorizedAccess):
		resp.Error(w, http.StatusForbidden, "unauthorized access to address")
	case errors.Is(err, entities.ErrCannotDeleteLastAddress):
		resp.Error(w, http.StatusBadRequest, "cannot delete the last address")
	case errors.Is(err, entities.ErrCannotDeleteDefaultAddress):
		resp.Error(w, http.StatusBadRequest, "cannot delete the only default address")
	case errors.Is(err, entities.ErrInvalidPhoneNumber):
		resp.Error(w, http.StatusBadRequest, "invalid phone number format")
	case errors.Is(err, entities.ErrRecipientNameRequired),
		errors.Is(err, entities.ErrPhoneNumberRequired),
		errors.Is(err, entities.ErrAddressLine1Required),
		errors.Is(err, entities.ErrWardRequired),
		errors.Is(err, entities.ErrDistrictRequired),
		errors.Is(err, entities.ErrCityRequired),
		errors.Is(err, entities.ErrInvalidAddressType):
		resp.Error(w, http.StatusBadRequest, err.Error())
	default:
		resp.Error(w, http.StatusInternalServerError, "internal server error")
	}
}

// --- Handlers ---

// CreateAddress creates a new address
// @Summary Create a new address
// @Description Create a new address for the authenticated user
// @Tags Address
// @Accept json
// @Produce json
// @Param request body api.CreateAddressRequest true "Address data"
// @Success 201 {object} resp.Envelope{data=api.AddressResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses [post]
// @Security Bearer
func (c *AddressController) CreateAddress(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req api.CreateAddressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	address := req.ToEntity(userID)
	if err := c.svc.Create(userID, address); err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.Created(w, api.ToResponse(address))
}

// GetAllAddresses gets all addresses for the authenticated user
// @Summary Get all addresses
// @Description Get all addresses for the authenticated user
// @Tags Address
// @Produce json
// @Success 200 {object} resp.Envelope{data=[]api.AddressResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses [get]
// @Security Bearer
func (c *AddressController) GetAllAddresses(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	addresses, err := c.svc.GetAllByUser(userID)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToResponseList(addresses))
}

// GetAddress gets an address by ID
// @Summary Get an address
// @Description Get an address by ID for the authenticated user
// @Tags Address
// @Produce json
// @Param id path int true "Address ID"
// @Success 200 {object} resp.Envelope{data=api.AddressResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses/{id} [get]
// @Security Bearer
func (c *AddressController) GetAddress(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	addressID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	address, err := c.svc.GetByID(userID, addressID)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToResponse(address))
}

// GetDefaultAddress gets the default address for the authenticated user
// @Summary Get default address
// @Description Get the default address for the authenticated user
// @Tags Address
// @Produce json
// @Success 200 {object} resp.Envelope{data=api.AddressResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses/default [get]
// @Security Bearer
func (c *AddressController) GetDefaultAddress(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	address, err := c.svc.GetDefault(userID)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToResponse(address))
}

// UpdateAddress updates an address
// @Summary Update an address
// @Description Update an address for the authenticated user
// @Tags Address
// @Accept json
// @Produce json
// @Param id path int true "Address ID"
// @Param request body api.UpdateAddressRequest true "Address data"
// @Success 200 {object} resp.Envelope{data=api.AddressResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses/{id} [put]
// @Security Bearer
func (c *AddressController) UpdateAddress(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	addressID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	var req api.UpdateAddressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	// Convert request to map for partial updates
	updates := make(map[string]any)
	if req.RecipientName != "" {
		updates["recipient_name"] = req.RecipientName
	}
	if req.PhoneNumber != "" {
		updates["phone_number"] = req.PhoneNumber
	}
	if req.AddressLine1 != "" {
		updates["address_line1"] = req.AddressLine1
	}
	if req.AddressLine2 != "" {
		updates["address_line2"] = req.AddressLine2
	}
	if req.Ward != "" {
		updates["ward"] = req.Ward
	}
	if req.District != "" {
		updates["district"] = req.District
	}
	if req.City != "" {
		updates["city"] = req.City
	}
	if req.AddressType != "" {
		updates["address_type"] = req.AddressType
	}

	address, err := c.svc.Update(userID, addressID, updates)
	if err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, api.ToResponse(address))
}

// DeleteAddress deletes an address
// @Summary Delete an address
// @Description Delete an address for the authenticated user
// @Tags Address
// @Param id path int true "Address ID"
// @Success 204
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses/{id} [delete]
// @Security Bearer
func (c *AddressController) DeleteAddress(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	addressID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	if err := c.svc.Delete(userID, addressID); err != nil {
		c.handleServiceError(w, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// SetDefaultAddress sets an address as default
// @Summary Set default address
// @Description Set an address as default for the authenticated user
// @Tags Address
// @Param id path int true "Address ID"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /addresses/{id}/set-default [patch]
// @Security Bearer
func (c *AddressController) SetDefaultAddress(w http.ResponseWriter, r *http.Request) {
	userID, ok := c.getUserID(r)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	addressID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	if err := c.svc.SetDefault(userID, addressID); err != nil {
		c.handleServiceError(w, err)
		return
	}

	resp.OK(w, map[string]string{
		"message": "address set as default successfully",
	})
}
