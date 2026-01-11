package api

import "github.com/google/uuid"

type CreatePayOSPaymentRequest struct {
	OrderID uuid.UUID `json:"order_id" validate:"required"`
}

type CreatePayOSPaymentResponse struct {
	CheckoutURL        string `json:"checkout_url"`
	PayosPaymentLinkID string `json:"payos_payment_link_id"`
	PayosOrderCode     uint64 `json:"payos_order_code"`
}

type PaymentStatusResponse struct {
	OrderID            uuid.UUID `json:"order_id"`
	Status             string    `json:"status"`
	CheckoutURL        string    `json:"checkout_url"`
	PayosPaymentLinkID string    `json:"payos_payment_link_id"`
	PayosOrderCode     uint64    `json:"payos_order_code"`
}

