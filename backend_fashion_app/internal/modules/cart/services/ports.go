package services

import (
	"context"
	"myfashion/internal/modules/cart/entities"
)

// CartRepository định nghĩa các phương thức để tương tác với dữ liệu giỏ hàng
type CartRepository interface {
	// --- Cart Methods ---
	GetOrCreateCartByUserID(ctx context.Context, userID uint) (*entities.Cart, error)
	GetCartByUserID(ctx context.Context, userID uint) (*entities.Cart, error)
	ClearCart(ctx context.Context, cartID uint) error

	// --- CartItem Methods ---
	FindItemByCartAndProduct(ctx context.Context, cartID, productID uint) (*entities.CartItem, error)
	FindItemByID(ctx context.Context, itemID uint) (*entities.CartItem, error)
	CreateItem(ctx context.Context, item *entities.CartItem) error
	UpdateItem(ctx context.Context, item *entities.CartItem) error
	DeleteItem(ctx context.Context, itemID uint) error
	GetItemsByCartID(ctx context.Context, cartID uint) ([]entities.CartItem, error)
}
