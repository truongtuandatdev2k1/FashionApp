package repositories

import (
	"myfashion/internal/modules/address/entities"

	"gorm.io/gorm"
)

type AddressGormRepository struct {
	db *gorm.DB
}

func NewAddressGormRepository(db *gorm.DB) *AddressGormRepository {
	return &AddressGormRepository{db: db}
}

// Create creates a new address
func (r *AddressGormRepository) Create(address *entities.Address) error {
	model := ToModel(address)
	if err := r.db.Create(model).Error; err != nil {
		return err
	}
	*address = *ToEntity(model)
	return nil
}

// FindByID finds an address by ID
func (r *AddressGormRepository) FindByID(id uint) (*entities.Address, error) {
	var model AddressModel
	if err := r.db.First(&model, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, entities.ErrAddressNotFound
		}
		return nil, err
	}
	return ToEntity(&model), nil
}

// FindByUserID finds all addresses for a user
func (r *AddressGormRepository) FindByUserID(userID uint) ([]*entities.Address, error) {
	var models []*AddressModel
	if err := r.db.Where("user_id = ?", userID).Order("is_default DESC, created_at DESC").Find(&models).Error; err != nil {
		return nil, err
	}
	return ToEntityList(models), nil
}

// FindDefaultByUserID finds the default address for a user
func (r *AddressGormRepository) FindDefaultByUserID(userID uint) (*entities.Address, error) {
	var model AddressModel
	if err := r.db.Where("user_id = ? AND is_default = ?", userID, true).First(&model).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, entities.ErrAddressNotFound
		}
		return nil, err
	}
	return ToEntity(&model), nil
}

// Update updates an address
func (r *AddressGormRepository) Update(address *entities.Address) error {
	model := ToModel(address)
	if err := r.db.Save(model).Error; err != nil {
		return err
	}
	*address = *ToEntity(model)
	return nil
}

// Delete deletes an address
func (r *AddressGormRepository) Delete(id uint) error {
	return r.db.Delete(&AddressModel{}, id).Error
}

// CountByUserID counts the number of addresses for a user
func (r *AddressGormRepository) CountByUserID(userID uint) (int64, error) {
	var count int64
	if err := r.db.Model(&AddressModel{}).Where("user_id = ?", userID).Count(&count).Error; err != nil {
		return 0, err
	}
	return count, nil
}

// UnsetDefaultForUser removes the default flag from all addresses of a user
func (r *AddressGormRepository) UnsetDefaultForUser(userID uint) error {
	return r.db.Model(&AddressModel{}).Where("user_id = ?", userID).Update("is_default", false).Error
}

// SetDefault sets an address as default and unsets all other addresses for the user
func (r *AddressGormRepository) SetDefault(userID, addressID uint) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// Unset all default addresses for the user
		if err := tx.Model(&AddressModel{}).Where("user_id = ?", userID).Update("is_default", false).Error; err != nil {
			return err
		}
		// Set the specified address as default
		if err := tx.Model(&AddressModel{}).Where("id = ? AND user_id = ?", addressID, userID).Update("is_default", true).Error; err != nil {
			return err
		}
		return nil
	})
}

// FindByIDAndUserID finds an address by ID and user ID (for authorization check)
func (r *AddressGormRepository) FindByIDAndUserID(id, userID uint) (*entities.Address, error) {
	var model AddressModel
	if err := r.db.Where("id = ? AND user_id = ?", id, userID).First(&model).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, entities.ErrAddressNotFound
		}
		return nil, err
	}
	return ToEntity(&model), nil
}
