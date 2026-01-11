package repositories

import "time"

type UserModel struct {
	ID          uint
	Email       string
	PhoneNumber string
	Role        string
	IsActive    bool
	Password    string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

func (UserModel) TableName() string { return "users" }

