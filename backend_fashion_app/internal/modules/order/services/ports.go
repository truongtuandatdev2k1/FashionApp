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
	ID               uint
	CartID           uint
	ProductVariantID uint
	Quantity         int
	PriceSnapshot    float64
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
	FindVariantByID(ctx context.Context, variantID uint) (ProductData, error)
	DecrementVariantStock(ctx context.Context, variantID uint, quantity int) error
}

// ProductData represents product data needed for order creation
type ProductData struct {
	VariantID uint
	ProductID uint
	Name      string  // Product Name
	ImageURL  string  // Product Image
	Price     float64 // Variant Price
	Stock     int     // Variant Stock
	SKU       string  // Variant SKU
	Color     string  // Variant Color
	Size      string  // Variant Size
}

// --- Promotion Service Interface ---

// PromotionValidationInput represents the data needed to validate promotions.
type PromotionValidationInput struct {
	Codes         []string
	OrderSubtotal float64
	ShippingFee   float64
}

// PromotionValidationOutput represents the result of a promotion validation.
type PromotionValidationOutput struct {
	TotalOrderDiscount    float64
	TotalShippingDiscount float64
	FinalAmount           float64
	AppliedPromotions     []AppliedPromotion
}

// AppliedPromotion represents a promotion that was successfully applied.
type AppliedPromotion struct {
	Code           string
	DiscountAmount float64
}

// PromotionService defines the interface for promotion-related operations needed by the order module.
type PromotionService interface {
	ValidatePromotions(ctx context.Context, userID uint, input PromotionValidationInput) (*PromotionValidationOutput, error)
	RecordUsage(ctx context.Context, codes []string) error
}
