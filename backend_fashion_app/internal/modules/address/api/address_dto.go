package api

import (
	"myfashion/internal/modules/address/entities"
	"time"
)

// CreateAddressRequest represents the request to create a new address
type CreateAddressRequest struct {
	RecipientName string               `json:"recipient_name" binding:"required"`
	PhoneNumber   string               `json:"phone_number" binding:"required"`
	AddressLine1  string               `json:"address_line1" binding:"required"`
	AddressLine2  string               `json:"address_line2"`
	Ward          string               `json:"ward" binding:"required"`
	District      string               `json:"district" binding:"required"`
	City          string               `json:"city" binding:"required"`
	AddressType   entities.AddressType `json:"address_type" binding:"required,oneof=home office other"`
	IsDefault     bool                 `json:"is_default"`
}

// UpdateAddressRequest represents the request to update an existing address
type UpdateAddressRequest struct {
	RecipientName string               `json:"recipient_name"`
	PhoneNumber   string               `json:"phone_number"`
	AddressLine1  string               `json:"address_line1"`
	AddressLine2  string               `json:"address_line2"`
	Ward          string               `json:"ward"`
	District      string               `json:"district"`
	City          string               `json:"city"`
	AddressType   entities.AddressType `json:"address_type" binding:"omitempty,oneof=home office other"`
}

// AddressResponse represents the response for an address
type AddressResponse struct {
	ID            uint                 `json:"id"`
	UserID        uint                 `json:"user_id"`
	RecipientName string               `json:"recipient_name"`
	PhoneNumber   string               `json:"phone_number"`
	AddressLine1  string               `json:"address_line1"`
	AddressLine2  string               `json:"address_line2,omitempty"`
	Ward          string               `json:"ward"`
	District      string               `json:"district"`
	City          string               `json:"city"`
	FullAddress   string               `json:"full_address"`
	AddressType   entities.AddressType `json:"address_type"`
	IsDefault     bool                 `json:"is_default"`
	CreatedAt     time.Time            `json:"created_at"`
	UpdatedAt     time.Time            `json:"updated_at"`
}

// ToEntity converts CreateAddressRequest to Address entity
func (r *CreateAddressRequest) ToEntity(userID uint) *entities.Address {
	return &entities.Address{
		UserID:        userID,
		RecipientName: r.RecipientName,
		PhoneNumber:   r.PhoneNumber,
		AddressLine1:  r.AddressLine1,
		AddressLine2:  r.AddressLine2,
		Ward:          r.Ward,
		District:      r.District,
		City:          r.City,
		AddressType:   r.AddressType,
		IsDefault:     r.IsDefault,
	}
}

// ToResponse converts Address entity to AddressResponse
func ToResponse(address *entities.Address) *AddressResponse {
	return &AddressResponse{
		ID:            address.ID,
		UserID:        address.UserID,
		RecipientName: address.RecipientName,
		PhoneNumber:   address.PhoneNumber,
		AddressLine1:  address.AddressLine1,
		AddressLine2:  address.AddressLine2,
		Ward:          address.Ward,
		District:      address.District,
		City:          address.City,
		FullAddress:   address.GetFullAddress(),
		AddressType:   address.AddressType,
		IsDefault:     address.IsDefault,
		CreatedAt:     address.CreatedAt,
		UpdatedAt:     address.UpdatedAt,
	}
}

// ToResponseList converts a list of Address entities to AddressResponse list
func ToResponseList(addresses []*entities.Address) []*AddressResponse {
	responses := make([]*AddressResponse, len(addresses))
	for i, address := range addresses {
		responses[i] = ToResponse(address)
	}
	return responses
}
