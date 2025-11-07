package repositories

import cen "myfashion/internal/modules/profile/entities"

func toCustomerModel(e *cen.CustomerProfile) *CustomerProfileModel {
	if e == nil {
		return nil
	}
	return &CustomerProfileModel{
		UserID:   e.UserID,
		FullName: e.FullName,
		Age:      e.Age,
		Gender:   e.Gender,
		Address:  e.Address,
		Tier:     e.Tier,
		ImgURL:   e.ImgURL,
	}
}

func toCustomerEntity(m *CustomerProfileModel) *cen.CustomerProfile {
	if m == nil {
		return nil
	}
	return &cen.CustomerProfile{
		UserID:   m.UserID,
		FullName: m.FullName,
		Age:      m.Age,
		Gender:   m.Gender,
		Address:  m.Address,
		Tier:     m.Tier,
		ImgURL:   m.ImgURL,
	}
}

func toShopModel(e *cen.ShopProfile) *ShopProfileModel {
	if e == nil {
		return nil
	}
	return &ShopProfileModel{
		UserID:   e.UserID,
		ShopName: e.ShopName,
		Address:  e.Address,
		ImgURL:   e.ImgURL,
	}
}

func toShopEntity(m *ShopProfileModel) *cen.ShopProfile {
	if m == nil {
		return nil
	}
	return &cen.ShopProfile{
		UserID:   m.UserID,
		ShopName: m.ShopName,
		Address:  m.Address,
		ImgURL:   m.ImgURL,
	}
}
