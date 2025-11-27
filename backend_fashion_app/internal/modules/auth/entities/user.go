package entities

import "time"

type Role string

const (
	RoleCustomer Role = "customer"
	RoleShop     Role = "shop"
)

type User struct {
	ID          uint      `gorm:"primaryKey"`
	Email       string    `gorm:"type:varchar(255);not null;unique"`
	Password    string    `gorm:"type:varchar(255);not null"`
	PhoneNumber string    `json:"phone_number" gorm:"column:phone_number;type:varchar(20);not null;unique"`
	Role        Role      `gorm:"type:enum('shop','customer');not null"`
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
}

func (u *User) IsShop() bool     { return u.Role == RoleShop }
func (u *User) IsCustomer() bool { return u.Role == RoleCustomer }
