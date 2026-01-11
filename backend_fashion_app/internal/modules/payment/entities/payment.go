package entities

import (
	"time"

	"github.com/google/uuid"
)

type PaymentStatus string

const (
	StatusPending   PaymentStatus = "PENDING"
	StatusPaid      PaymentStatus = "PAID"
	StatusFailed    PaymentStatus = "FAILED"
	StatusCancelled PaymentStatus = "CANCELLED"
	StatusExpired   PaymentStatus = "EXPIRED"
)

type Payment struct {
	ID                 uint
	OrderID            uuid.UUID
	Provider           string
	Amount             int
	Status             PaymentStatus
	PayosOrderCode     uint64
	PayosPaymentLinkID string
	CheckoutURL        string
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

