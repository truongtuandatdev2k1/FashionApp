package repositories

import "time"

type AddressModel struct {
	ID            uint      `gorm:"primaryKey"`
	UserID        uint      `gorm:"not null;index:idx_user_id"`
	RecipientName string    `gorm:"size:255;not null"`
	PhoneNumber   string    `gorm:"size:20;not null"`
	AddressLine1  string    `gorm:"size:500;not null"`
	AddressLine2  string    `gorm:"size:500"`
	Ward          string    `gorm:"size:100;not null"`
	District      string    `gorm:"size:100;not null"`
	City          string    `gorm:"size:100;not null"`
	AddressType   string    `gorm:"size:20;not null;default:'home'"`
	IsDefault     bool      `gorm:"default:false;index:idx_user_default"`
	CreatedAt     time.Time `gorm:"autoCreateTime"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime"`
}

func (AddressModel) TableName() string {
	return "addresses"
}
