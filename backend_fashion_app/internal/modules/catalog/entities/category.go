package entities

import "time"

type Category struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"type:varchar(255);not null;unique"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	// Many-to-many relationship
	Products []Product `gorm:"many2many:product_categories;"`
}

func (Category) TableName() string {
	return "categories"
}
