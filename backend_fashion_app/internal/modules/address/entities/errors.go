package entities

import "errors"

var (
	// Validation errors
	ErrRecipientNameRequired = errors.New("recipient name is required")
	ErrPhoneNumberRequired   = errors.New("phone number is required")
	ErrAddressLine1Required  = errors.New("address line 1 is required")
	ErrWardRequired          = errors.New("ward is required")
	ErrDistrictRequired      = errors.New("district is required")
	ErrCityRequired          = errors.New("city is required")
	ErrInvalidAddressType    = errors.New("invalid address type")

	// Business logic errors
	ErrAddressNotFound            = errors.New("address not found")
	ErrUnauthorizedAccess         = errors.New("unauthorized access to address")
	ErrCannotDeleteDefaultAddress = errors.New("cannot delete the only default address")
	ErrCannotDeleteLastAddress    = errors.New("cannot delete the last address")
	ErrInvalidPhoneNumber         = errors.New("invalid phone number format")
)
