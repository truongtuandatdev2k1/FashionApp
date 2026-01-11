package repositories

import (
	"time"

	"github.com/google/uuid"
)

type PaymentModel struct {
	ID                 uint      `gorm:"primaryKey"`
	OrderID            uuid.UUID `gorm:"type:char(36);uniqueIndex;not null"`
	Provider           string    `gorm:"type:varchar(20);not null"`
	Amount             int       `gorm:"not null"`
	Status             string    `gorm:"type:varchar(20);index;not null"`
	PayosOrderCode     uint64    `gorm:"uniqueIndex;not null"`
	PayosPaymentLinkID string    `gorm:"type:varchar(100);uniqueIndex"`
	CheckoutURL        string    `gorm:"type:text"`
	RawWebhook         string    `gorm:"type:longtext"`
	CreatedAt          time.Time `gorm:"autoCreateTime"`
	UpdatedAt          time.Time `gorm:"autoUpdateTime"`
}

func (PaymentModel) TableName() string { return "payments" }

