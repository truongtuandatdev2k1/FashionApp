package repositories

import (
	"myfashion/internal/modules/cart/entities"
)

// ToCartEntity chuyển đổi từ CartModel sang Cart entity
func ToCartEntity(m *CartModel) *entities.Cart {
	if m == nil {
		return nil
	}
	return &entities.Cart{
		ID:        m.ID,
		UserID:    m.UserID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
	}
}

// ToCartModel chuyển đổi từ Cart entity sang CartModel
func ToCartModel(e *entities.Cart) *CartModel {
	if e == nil {
		return nil
	}
	return &CartModel{
		ID:        e.ID,
		UserID:    e.UserID,
		CreatedAt: e.CreatedAt,
		UpdatedAt: e.UpdatedAt,
	}
}

// ToCartItemEntity chuyển đổi từ CartItemModel sang CartItem entity
func ToCartItemEntity(m *CartItemModel) *entities.CartItem {
	if m == nil {
		return nil
	}
	return &entities.CartItem{
		ID:            m.ID,
		CartID:        m.CartID,
		ProductID:     m.ProductID,
		Quantity:      m.Quantity,
		PriceSnapshot: m.PriceSnapshot,
		CreatedAt:     m.CreatedAt,
		UpdatedAt:     m.UpdatedAt,
	}
}

// ToCartItemModel chuyển đổi từ CartItem entity sang CartItemModel
func ToCartItemModel(e *entities.CartItem) *CartItemModel {
	if e == nil {
		return nil
	}
	return &CartItemModel{
		ID:            e.ID,
		CartID:        e.CartID,
		ProductID:     e.ProductID,
		Quantity:      e.Quantity,
		PriceSnapshot: e.PriceSnapshot,
		CreatedAt:     e.CreatedAt,
		UpdatedAt:     e.UpdatedAt,
	}
}
