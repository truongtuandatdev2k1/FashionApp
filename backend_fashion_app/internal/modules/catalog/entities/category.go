package entities

import "time"

type Category struct {
	ID        uint   `gorm:"primaryKey"`
	Name      string `gorm:"type:varchar(255);not null;unique"`
	CreatedAt time.Time
	UpdatedAt time.Time
}
