package repositories

import (
	"time"

	authRepositories "myfashion/internal/modules/auth/repositories"
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

	ApplicableUsers []PromotionUserModel `gorm:"foreignKey:PromotionID;constraint:OnDelete:CASCADE"`
	ApplicableTiers []PromotionTierModel `gorm:"foreignKey:PromotionID;constraint:OnDelete:CASCADE"`
}

func (PromotionModel) TableName() string {
	return "promotions"
}

// PromotionUserModel ánh xạ tới bảng `promotion_users`
type PromotionUserModel struct {
	PromotionID uint `gorm:"primaryKey;autoIncrement:false"`
	UserID      uint `gorm:"primaryKey;autoIncrement:false"`

	Promotion PromotionModel             `gorm:"foreignKey:PromotionID;constraint:OnDelete:CASCADE"`
	User      authRepositories.UserModel `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

func (PromotionUserModel) TableName() string {
	return "promotion_users"
}

// PromotionTierModel ánh xạ tới bảng `promotion_tiers`
type PromotionTierModel struct {
	PromotionID uint   `gorm:"primaryKey;autoIncrement:false"`
	TierName    string `gorm:"primaryKey;size:50;autoIncrement:false"`

	Promotion PromotionModel `gorm:"foreignKey:PromotionID;constraint:OnDelete:CASCADE"`
}

func (PromotionTierModel) TableName() string {
	return "promotion_tiers"
}
