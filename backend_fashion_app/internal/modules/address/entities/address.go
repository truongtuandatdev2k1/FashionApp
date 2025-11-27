package entities

import "time"

type AddressType string

const (
	AddressTypeHome   AddressType = "home"
	AddressTypeOffice AddressType = "office"
	AddressTypeOther  AddressType = "other"
)

type Address struct {
	ID            uint        `gorm:"primaryKey"`
	UserID        uint        `gorm:"not null;index"`
	RecipientName string      `gorm:"type:varchar(255);not null"`
	PhoneNumber   string      `gorm:"type:varchar(20);not null"`
	AddressLine1  string      `gorm:"type:varchar(255);not null"`
	AddressLine2  string      `gorm:"type:varchar(255)"`
	Ward          string      `gorm:"type:varchar(100);not null"`
	District      string      `gorm:"type:varchar(100);not null"`
	City          string      `gorm:"type:varchar(100);not null"`
	AddressType   AddressType `gorm:"type:varchar(20)"`
	IsDefault     bool        `gorm:"default:false"`
	CreatedAt     time.Time   `gorm:"autoCreateTime"`
	UpdatedAt     time.Time   `gorm:"autoUpdateTime"`
}

func (Address) TableName() string {
	return "addresses"
}

// GetFullAddress returns the complete formatted address
func (a *Address) GetFullAddress() string {
	fullAddr := a.AddressLine1
	if a.AddressLine2 != "" {
		fullAddr += ", " + a.AddressLine2
	}
	fullAddr += ", " + a.Ward + ", " + a.District + ", " + a.City
	return fullAddr
}

// Validate checks if the address has all required fields
func (a *Address) Validate() error {
	if a.RecipientName == "" {
		return ErrRecipientNameRequired
	}
	if a.PhoneNumber == "" {
		return ErrPhoneNumberRequired
	}
	if a.AddressLine1 == "" {
		return ErrAddressLine1Required
	}
	if a.Ward == "" {
		return ErrWardRequired
	}
	if a.District == "" {
		return ErrDistrictRequired
	}
	if a.City == "" {
		return ErrCityRequired
	}
	if !a.IsValidAddressType() {
		return ErrInvalidAddressType
	}
	return nil
}

// IsValidAddressType checks if the address type is valid
func (a *Address) IsValidAddressType() bool {
	return a.AddressType == AddressTypeHome ||
		a.AddressType == AddressTypeOffice ||
		a.AddressType == AddressTypeOther
}
