package repositories

import "myfashion/internal/modules/auth/repositories"

type CustomerProfileModel struct {
	UserID   uint   `gorm:"primaryKey"`
	FullName string `gorm:"size:255"`
	Age      int
	Gender   string `gorm:"size:10"`
	Address  string `gorm:"type:text"`
	Tier     string `gorm:"size:50;default:'bronze'"` // Hạng thành viên: bronze, silver, gold
	ImgURL   string `gorm:"size:500"`

	User repositories.UserModel `gorm:"foreignKey:UserID;references:ID;constraint:OnDelete:CASCADE"`
}

func (CustomerProfileModel) TableName() string { return "customer_profiles" }

type ShopProfileModel struct {
	UserID   uint   `gorm:"primaryKey"`
	ShopName string `gorm:"size:255"`
	Address  string `gorm:"type:text"`
	ImgURL   string `gorm:"size:500"`

	User repositories.UserModel `gorm:"foreignKey:UserID;references:ID;constraint:OnDelete:CASCADE"`
}

func (ShopProfileModel) TableName() string { return "shop_profiles" }
