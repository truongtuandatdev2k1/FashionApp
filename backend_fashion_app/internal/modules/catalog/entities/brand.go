package entities

import "time"

type Brand struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Name      string    `gorm:"type:varchar(255);not null;unique" json:"name"`
	LogoURL   string    `gorm:"column:logo_url;type:varchar(255)" json:"logo_url"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}
