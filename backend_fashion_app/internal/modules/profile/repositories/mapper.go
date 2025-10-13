package repositories

import cen "myfashion/internal/modules/profile/entities"

func toCustomerModel(e *cen.CustomerProfile) *CustomerProfileModel {
	if e == nil {
		return nil
	}
	return &CustomerProfileModel{
		UserID: e.UserID, FullName: e.FullName, Gender: e.Gender,
		Birthdate: e.Birthdate, HeightCM: e.HeightCM, WeightKG: e.WeightKG,
	}
}
func toCustomerEntity(m *CustomerProfileModel) *cen.CustomerProfile {
	if m == nil {
		return nil
	}
	return &cen.CustomerProfile{
		UserID: m.UserID, FullName: m.FullName, Gender: m.Gender,
		Birthdate: m.Birthdate, HeightCM: m.HeightCM, WeightKG: m.WeightKG,
	}
}
func toShopModel(e *cen.ShopProfile) *ShopProfileModel {
	if e == nil {
		return nil
	}
	return &ShopProfileModel{
		UserID: e.UserID, ShopName: e.ShopName, Address: e.Address, Phone: e.Phone,
	}
}
func toShopEntity(m *ShopProfileModel) *cen.ShopProfile {
	if m == nil {
		return nil
	}
	return &cen.ShopProfile{
		UserID: m.UserID, ShopName: m.ShopName, Address: m.Address, Phone: m.Phone,
	}
}
