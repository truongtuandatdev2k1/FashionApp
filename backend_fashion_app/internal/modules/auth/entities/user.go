package entities

import "time"

type Role string

const (
	RoleCustomer Role = "customer"
	RoleShop     Role = "shop"
)

type Provider string

const (
	ProviderLocal  Provider = "local"
	ProviderGoogle Provider = "google"
)

type User struct {
	ID          uint
	Email       string
	Password    string
	PhoneNumber string `json:"phone_number" gorm:"column:phone_number"`
	Role        Role
	Provider    Provider
	GoogleSub   *string // Thay đổi thành pointer để có thể là NULL
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

func (u *User) IsShop() bool     { return u.Role == RoleShop }
func (u *User) IsCustomer() bool { return u.Role == RoleCustomer }
