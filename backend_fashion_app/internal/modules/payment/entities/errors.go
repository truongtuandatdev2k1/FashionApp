package entities

import "errors"

var (
	ErrPaymentNotFound   = errors.New("payment not found")
	ErrInvalidWebhook    = errors.New("invalid webhook")
	ErrInvalidOrder      = errors.New("invalid order")
	ErrPaymentNotAllowed = errors.New("payment not allowed")
)

