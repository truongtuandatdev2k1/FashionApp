package services

import (
	"myfashion/internal/modules/address/entities"
	"regexp"
)

type AddressService struct {
	repo AddressRepository
}

func NewAddressService(repo AddressRepository) *AddressService {
	return &AddressService{repo: repo}
}

// Create creates a new address with business logic
func (s *AddressService) Create(userID uint, address *entities.Address) error {
	// Set user ID
	address.UserID = userID

	// Validate address
	if err := address.Validate(); err != nil {
		return err
	}

	// Validate phone number format
	if !s.isValidPhoneNumber(address.PhoneNumber) {
		return entities.ErrInvalidPhoneNumber
	}

	// Check if this is the first address
	count, err := s.repo.CountByUserID(userID)
	if err != nil {
		return err
	}

	// If this is the first address, automatically set as default
	if count == 0 {
		address.IsDefault = true
	} else if address.IsDefault {
		// If user wants to set this as default, unset other defaults
		if err := s.repo.UnsetDefaultForUser(userID); err != nil {
			return err
		}
	}

	return s.repo.Create(address)
}

// GetByID gets an address by ID with authorization check
func (s *AddressService) GetByID(userID, addressID uint) (*entities.Address, error) {
	address, err := s.repo.FindByIDAndUserID(addressID, userID)
	if err != nil {
		return nil, err
	}
	return address, nil
}

// GetAllByUser gets all addresses for a user
func (s *AddressService) GetAllByUser(userID uint) ([]*entities.Address, error) {
	return s.repo.FindByUserID(userID)
}

// GetDefault gets the default address for a user
func (s *AddressService) GetDefault(userID uint) (*entities.Address, error) {
	return s.repo.FindDefaultByUserID(userID)
}

// Update updates an address with business logic
func (s *AddressService) Update(userID, addressID uint, updates map[string]any) (*entities.Address, error) {
	// Check if address exists and belongs to user
	address, err := s.repo.FindByIDAndUserID(addressID, userID)
	if err != nil {
		return nil, err
	}

	// Apply updates
	if recipientName, ok := updates["recipient_name"].(string); ok && recipientName != "" {
		address.RecipientName = recipientName
	}
	if phoneNumber, ok := updates["phone_number"].(string); ok && phoneNumber != "" {
		if !s.isValidPhoneNumber(phoneNumber) {
			return nil, entities.ErrInvalidPhoneNumber
		}
		address.PhoneNumber = phoneNumber
	}
	if addressLine1, ok := updates["address_line1"].(string); ok && addressLine1 != "" {
		address.AddressLine1 = addressLine1
	}
	if addressLine2, ok := updates["address_line2"].(string); ok {
		address.AddressLine2 = addressLine2
	}
	if ward, ok := updates["ward"].(string); ok && ward != "" {
		address.Ward = ward
	}
	if district, ok := updates["district"].(string); ok && district != "" {
		address.District = district
	}
	if city, ok := updates["city"].(string); ok && city != "" {
		address.City = city
	}
	if addressType, ok := updates["address_type"].(entities.AddressType); ok {
		address.AddressType = addressType
	}

	// Validate updated address
	if err := address.Validate(); err != nil {
		return nil, err
	}

	// Update in database
	if err := s.repo.Update(address); err != nil {
		return nil, err
	}

	return address, nil
}

// Delete deletes an address with business logic
func (s *AddressService) Delete(userID, addressID uint) error {
	// Check if address exists and belongs to user
	address, err := s.repo.FindByIDAndUserID(addressID, userID)
	if err != nil {
		return err
	}

	// Count total addresses
	count, err := s.repo.CountByUserID(userID)
	if err != nil {
		return err
	}

	// If this is the default address and there are other addresses
	if address.IsDefault && count > 1 {
		// Find another address to set as default
		addresses, err := s.repo.FindByUserID(userID)
		if err != nil {
			return err
		}

		// Delete the address first
		if err := s.repo.Delete(addressID); err != nil {
			return err
		}

		// Set the first remaining address as default
		for _, addr := range addresses {
			if addr.ID != addressID {
				if err := s.repo.SetDefault(userID, addr.ID); err != nil {
					return err
				}
				break
			}
		}
		return nil
	}

	// If this is the only address and it's default, don't allow deletion
	if address.IsDefault && count == 1 {
		return entities.ErrCannotDeleteLastAddress
	}

	// Delete the address
	return s.repo.Delete(addressID)
}

// SetDefault sets an address as default
func (s *AddressService) SetDefault(userID, addressID uint) error {
	// Check if address exists and belongs to user
	_, err := s.repo.FindByIDAndUserID(addressID, userID)
	if err != nil {
		return err
	}

	// Set as default (this will unset other defaults in the repository)
	return s.repo.SetDefault(userID, addressID)
}

// isValidPhoneNumber validates Vietnamese phone number format
// Format: 10 digits starting with 0
func (s *AddressService) isValidPhoneNumber(phone string) bool {
	// Vietnamese phone number: 10 digits, starts with 0
	matched, _ := regexp.MatchString(`^0\d{9}$`, phone)
	return matched
}
