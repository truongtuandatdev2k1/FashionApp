package repositories

import "myfashion/internal/modules/address/entities"

// ToModel converts Address entity to AddressModel
func ToModel(address *entities.Address) *AddressModel {
	return &AddressModel{
		ID:            address.ID,
		UserID:        address.UserID,
		RecipientName: address.RecipientName,
		PhoneNumber:   address.PhoneNumber,
		AddressLine1:  address.AddressLine1,
		AddressLine2:  address.AddressLine2,
		Ward:          address.Ward,
		District:      address.District,
		City:          address.City,
		AddressType:   string(address.AddressType),
		IsDefault:     address.IsDefault,
		CreatedAt:     address.CreatedAt,
		UpdatedAt:     address.UpdatedAt,
	}
}

// ToEntity converts AddressModel to Address entity
func ToEntity(model *AddressModel) *entities.Address {
	return &entities.Address{
		ID:            model.ID,
		UserID:        model.UserID,
		RecipientName: model.RecipientName,
		PhoneNumber:   model.PhoneNumber,
		AddressLine1:  model.AddressLine1,
		AddressLine2:  model.AddressLine2,
		Ward:          model.Ward,
		District:      model.District,
		City:          model.City,
		AddressType:   entities.AddressType(model.AddressType),
		IsDefault:     model.IsDefault,
		CreatedAt:     model.CreatedAt,
		UpdatedAt:     model.UpdatedAt,
	}
}

// ToEntityList converts a list of AddressModel to Address entities
func ToEntityList(models []*AddressModel) []*entities.Address {
	entities := make([]*entities.Address, len(models))
	for i, model := range models {
		entities[i] = ToEntity(model)
	}
	return entities
}
