package repositories

import (
	"context"
	"errors"

	"gorm.io/gorm"

	addressEntities "myfashion/internal/modules/address/entities"
	cartEntities "myfashion/internal/modules/cart/entities"
	catalogEntities "myfashion/internal/modules/catalog/entities"
	"myfashion/internal/modules/order/services"
)

// CartRepositoryAdapter adapts cart repository for order service
type CartRepositoryAdapter struct {
	db *gorm.DB
}

func NewCartRepositoryAdapter(db *gorm.DB) *CartRepositoryAdapter {
	return &CartRepositoryAdapter{db: db}
}

func (r *CartRepositoryAdapter) FindItemsByIDs(ctx context.Context, itemIDs []uint, userID uint) ([]services.CartItemData, error) {
	var cartItems []cartEntities.CartItem

	// Join with carts table to verify ownership
	err := r.db.WithContext(ctx).
		Joins("JOIN carts ON carts.id = cart_items.cart_id").
		Where("cart_items.id IN ? AND carts.user_id = ?", itemIDs, userID).
		Find(&cartItems).Error

	if err != nil {
		return nil, err
	}

	// Convert to service data type
	result := make([]services.CartItemData, len(cartItems))
	for i, item := range cartItems {
		result[i] = services.CartItemData{
			ID:               item.ID,
			CartID:           item.CartID,
			ProductVariantID: item.ProductVariantID,
			Quantity:         item.Quantity,
			PriceSnapshot:    item.PriceSnapshot,
		}
	}

	return result, nil
}

func (r *CartRepositoryAdapter) DeleteItems(ctx context.Context, itemIDs []uint) error {
	return r.db.WithContext(ctx).
		Where("id IN ?", itemIDs).
		Delete(&cartEntities.CartItem{}).Error
}

// AddressRepositoryAdapter adapts address repository for order service
type AddressRepositoryAdapter struct {
	db *gorm.DB
}

func NewAddressRepositoryAdapter(db *gorm.DB) *AddressRepositoryAdapter {
	return &AddressRepositoryAdapter{db: db}
}

func (r *AddressRepositoryAdapter) FindByIDAndUserID(ctx context.Context, addressID, userID uint) (services.AddressData, error) {
	var address addressEntities.Address

	err := r.db.WithContext(ctx).
		Where("id = ? AND user_id = ?", addressID, userID).
		First(&address).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return services.AddressData{}, errors.New("address not found")
		}
		return services.AddressData{}, err
	}

	return services.AddressData{
		ID:            address.ID,
		RecipientName: address.RecipientName,
		PhoneNumber:   address.PhoneNumber,
		AddressLine1:  address.AddressLine1,
		AddressLine2:  address.AddressLine2,
		Ward:          address.Ward,
		District:      address.District,
		City:          address.City,
	}, nil
}

// ProductRepositoryAdapter adapts product repository for order service
type ProductRepositoryAdapter struct {
	db *gorm.DB
}

func NewProductRepositoryAdapter(db *gorm.DB) *ProductRepositoryAdapter {
	return &ProductRepositoryAdapter{db: db}
}

func (r *ProductRepositoryAdapter) FindVariantByID(ctx context.Context, variantID uint) (services.ProductData, error) {
	var variant catalogEntities.ProductVariant

	err := r.db.WithContext(ctx).
		Preload("Product").
		Preload("ProductColor").
		Where("id = ?", variantID).
		First(&variant).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return services.ProductData{}, errors.New("product variant not found")
		}
		return services.ProductData{}, err
	}

	return services.ProductData{
		VariantID: variant.ID,
		ProductID: variant.ProductID,
		Name:      variant.Product.Name,
		ImageURL:  variant.Product.ImageURL,
		Price:     variant.Product.PriceAfter,
		Stock:     variant.Stock,
		SKU:       variant.Sku,
		Color:     variant.ProductColor.ColorName,
		Size:      variant.SizeCode,
	}, nil
}

func (r *ProductRepositoryAdapter) DecrementVariantStock(ctx context.Context, variantID uint, quantity int) error {
	result := r.db.WithContext(ctx).
		Model(&catalogEntities.ProductVariant{}).
		Where("id = ? AND stock >= ?", variantID, quantity).
		Update("stock", gorm.Expr("stock - ?", quantity))

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("insufficient stock or product variant not found")
	}

	return nil
}
