package entities

import "time"

type Color struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"type:varchar(50);not null;unique"`
	HexCode   string    `gorm:"type:varchar(7);not null;unique"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`
}

func (Color) TableName() string {
	return "colors"
}
