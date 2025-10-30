package services

import "myfashion/internal/modules/address/entities"

type AddressRepository interface {
	Create(address *entities.Address) error
	FindByID(id uint) (*entities.Address, error)
	FindByUserID(userID uint) ([]*entities.Address, error)
	FindDefaultByUserID(userID uint) (*entities.Address, error)
	FindByIDAndUserID(id, userID uint) (*entities.Address, error)
	Update(address *entities.Address) error
	Delete(id uint) error
	CountByUserID(userID uint) (int64, error)
	UnsetDefaultForUser(userID uint) error
	SetDefault(userID, addressID uint) error
}
