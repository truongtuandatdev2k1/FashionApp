package repositories

import "myfashion/internal/modules/auth/entities"

func toModel(e *entities.User) *UserModel {
	if e == nil {
		return nil
	}
	return &UserModel{
		ID: e.ID, Email: e.Email, Password: e.Password, PhoneNumber: e.PhoneNumber,
		Role: string(e.Role), Provider: string(e.Provider), GoogleSub: e.GoogleSub,
		CreatedAt: e.CreatedAt, UpdatedAt: e.UpdatedAt,
	}
}

func toEntity(m *UserModel) *entities.User {
	if m == nil {
		return nil
	}
	return &entities.User{
		ID: m.ID, Email: m.Email, Password: m.Password, PhoneNumber: m.PhoneNumber,
		Role: entities.Role(m.Role), Provider: entities.Provider(m.Provider), GoogleSub: m.GoogleSub,
		CreatedAt: m.CreatedAt, UpdatedAt: m.UpdatedAt,
	}
}
