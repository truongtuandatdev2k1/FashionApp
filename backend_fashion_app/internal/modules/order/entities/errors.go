package entities

import "errors"

var (
	ErrOrderNotFound           = errors.New("order not found")
	ErrOrderCannotBeCancelled  = errors.New("order cannot be cancelled")
	ErrOrderCannotBeConfirmed  = errors.New("order cannot be confirmed")
	ErrInvalidStatusTransition = errors.New("invalid status transition")
	ErrEmptyCart               = errors.New("cart is empty")
	ErrInvalidShippingAddress  = errors.New("invalid shipping address")
	ErrUnauthorizedAccess      = errors.New("unauthorized access to order")
)
