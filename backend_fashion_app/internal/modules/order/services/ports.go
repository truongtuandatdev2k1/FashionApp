package services

import (
	"context"

	"myfashion/internal/modules/order/entities"

	"github.com/google/uuid"
)

// OrderRepository defines the interface for order data access
type OrderRepository interface {
	Create(ctx context.Context, order *entities.Order) error
	FindByID(ctx context.Context, id uuid.UUID) (*entities.Order, error)
	FindByOrderNumber(ctx context.Context, orderNumber string) (*entities.Order, error)
	FindByCustomerID(ctx context.Context, customerID uint, limit, offset int) ([]*entities.Order, int64, error)
	FindByShopID(ctx context.Context, shopID uint, limit, offset int) ([]*entities.Order, int64, error)
	FindByCustomerIDAndStatus(ctx context.Context, customerID uint, status entities.OrderStatus, limit, offset int) ([]*entities.Order, int64, error)
	Update(ctx context.Context, order *entities.Order) error
	Delete(ctx context.Context, id uuid.UUID) error
}

// CartRepository defines the interface for cart data access
type CartRepository interface {
	FindItemsByIDs(ctx context.Context, itemIDs []uint, userID uint) ([]CartItemData, error)
	DeleteItems(ctx context.Context, itemIDs []uint) error
}

// CartItemData represents cart item data needed for order creation
type CartItemData struct {
	ID            uint
	CartID        uint
	ProductID     uint
	Quantity      int
	PriceSnapshot float64
}

// AddressRepository defines the interface for address data access
type AddressRepository interface {
	FindByIDAndUserID(ctx context.Context, addressID, userID uint) (AddressData, error)
}

// AddressData represents address data needed for order creation
type AddressData struct {
	ID            uint
	RecipientName string
	PhoneNumber   string
	AddressLine1  string
	AddressLine2  string
	Ward          string
	District      string
	City          string
}

// ProductRepository defines the interface for product data access
type ProductRepository interface {
	FindByID(ctx context.Context, productID uint) (ProductData, error)
	DecrementStock(ctx context.Context, productID uint, quantity int) error
}

// ProductData represents product data needed for order creation
type ProductData struct {
	ID         uint
	Name       string
	ImageURL   string
	PriceAfter float64
	Stock      int
}
