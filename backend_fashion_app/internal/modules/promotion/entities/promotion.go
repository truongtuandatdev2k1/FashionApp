package entities

import (
	"time"
)

// PromotionType định nghĩa các loại khuyến mãi
type PromotionType string

const (
	TypeOrderFixed      PromotionType = "order_fixed"
	TypeOrderPercentage PromotionType = "order_percentage"
	TypeShippingFixed   PromotionType = "shipping_fixed"
	TypeFreeShipping    PromotionType = "free_shipping"
)

// TargetGroup định nghĩa nhóm khách hàng mục tiêu
type TargetGroup string

const (
	TargetAllCustomers  TargetGroup = "all"
	TargetNewCustomers  TargetGroup = "new_customer"
	TargetSpecificUsers TargetGroup = "specific_users"
	TargetCustomerTier  TargetGroup = "customer_tier"
)

// Promotion là entity chính cho một chương trình khuyến mãi
type Promotion struct {
	ID              uint          `gorm:"primaryKey"`
	Code            string        `gorm:"type:varchar(50);unique;not null"`
	Name            string        `gorm:"type:varchar(255);not null"`
	Description     string        `gorm:"type:text"`
	Type            PromotionType `gorm:"type:varchar(20);not null"`
	Value           float64       `gorm:"type:decimal(10,2);not null"`
	MaxDiscount     *float64      `gorm:"type:decimal(10,2)"`
	MinOrderValue   float64       `gorm:"type:decimal(10,2);default:0"`
	StartDate       time.Time     `gorm:"not null"`
	EndDate         time.Time     `gorm:"not null"`
	UsageLimit      int           `gorm:"default:0"`
	UsageCount      int           `gorm:"default:0"`
	UserUsageLimit  int           `gorm:"default:0"`
	IsActive        bool          `gorm:"default:true"`
	IsStackable     bool          `gorm:"default:false"`
	TargetGroup     TargetGroup   `gorm:"type:varchar(20);not null"`
	ApplicableTiers []string      `gorm:"-"` // Not a DB field, handled by logic
	ApplicableUsers []uint        `gorm:"-"` // Not a DB field, handled by logic
	CreatedAt       time.Time     `gorm:"autoCreateTime"`
	UpdatedAt       time.Time     `gorm:"autoUpdateTime"`
}

func (Promotion) TableName() string {
	return "promotions"
}
