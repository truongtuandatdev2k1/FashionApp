package repositories

import (
	"time"
)

// PromotionModel ánh xạ tới bảng `promotions`
type PromotionModel struct {
	ID             uint      `gorm:"primaryKey"`
	Code           string    `gorm:"size:50;uniqueIndex;not null"`
	Name           string    `gorm:"size:255;not null"`
	Description    string    `gorm:"type:text"`
	Type           string    `gorm:"size:50;not null"`
	Value          float64   `gorm:"type:decimal(15,2);not null"`
	MaxDiscount    *float64  `gorm:"type:decimal(15,2)"`
	MinOrderValue  float64   `gorm:"type:decimal(15,2);default:0"`
	StartDate      time.Time `gorm:"not null"`
	EndDate        time.Time `gorm:"not null"`
	UsageLimit     int       `gorm:"default:0"`
	UsageCount     int       `gorm:"default:0"`
	UserUsageLimit int       `gorm:"default:1"`
	IsActive       bool      `gorm:"default:true"`
	IsStackable    bool      `gorm:"default:false"`
	TargetGroup    string    `gorm:"size:50;not null"`
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime"`
}

func (PromotionModel) TableName() string {
	return "promotions"
}

// PromotionUserModel ánh xạ tới bảng `promotion_users`
type PromotionUserModel struct {
	PromotionID uint `gorm:"primaryKey"`
	UserID      uint `gorm:"primaryKey"`
}

func (PromotionUserModel) TableName() string {
	return "promotion_users"
}

// PromotionTierModel ánh xạ tới bảng `promotion_tiers`
type PromotionTierModel struct {
	PromotionID uint   `gorm:"primaryKey"`
	TierName    string `gorm:"primaryKey;size:50"`
}

func (PromotionTierModel) TableName() string {
	return "promotion_tiers"
}
