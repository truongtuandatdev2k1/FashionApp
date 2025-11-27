package repositories

import (
	"context"
	"errors"
	"myfashion/internal/modules/cart/services"
	catalogEntities "myfashion/internal/modules/catalog/entities"
	"strings"

	"gorm.io/gorm"
)

// ProductRepositoryAdapter adapts the catalog's product repository for the cart service.
type ProductRepositoryAdapter struct {
	db *gorm.DB
}

func NewProductRepositoryAdapter(db *gorm.DB) *ProductRepositoryAdapter {
	return &ProductRepositoryAdapter{db: db}
}

// GetVariantByID retrieves product variant information needed for the cart.
func (r *ProductRepositoryAdapter) GetVariantByID(ctx context.Context, id uint) (*services.VariantData, error) {
	var variant catalogEntities.ProductVariant

	err := r.db.WithContext(ctx).
		Preload("Product").
		Preload("ProductColor").
		First(&variant, id).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product variant not found")
		}
		return nil, err
	}

	imageURL := variant.Product.ImageURL

	return &services.VariantData{
		VariantID: variant.ID,
		ProductID: variant.ProductID,
		Name:      variant.Product.Name,
		ImageURL:  imageURL,
		Price:     variant.Product.PriceAfter,
		Stock:     variant.Stock,
		SKU:       variant.Sku,
		Color:     variant.ProductColor.ColorName,
		ColorHex:  variant.ProductColor.ColorHex,
		Size:      variant.SizeCode,
	}, nil
}

// ResolveVariantByAttr resolves a variant by (productID, colorHex, sizeCode)
func (r *ProductRepositoryAdapter) ResolveVariantByAttr(ctx context.Context, productID uint, colorHex, sizeCode string) (*services.VariantData, error) {
	colorHex = strings.ToUpper(strings.TrimSpace(colorHex))
	sizeCode = strings.ToUpper(strings.TrimSpace(sizeCode))

	var variant catalogEntities.ProductVariant
	err := r.db.WithContext(ctx).
		Joins("JOIN product_colors ON product_colors.id = product_variants.product_color_id").
		Joins("JOIN products ON products.id = product_variants.product_id").
		Where("product_variants.product_id = ? AND UPPER(product_colors.color_hex) = ? AND UPPER(product_variants.size_code) = ?", productID, colorHex, sizeCode).
		Preload("Product").
		Preload("ProductColor").
		First(&variant).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product variant not found")
		}
		return nil, err
	}
	return &services.VariantData{
		VariantID: variant.ID,
		ProductID: variant.ProductID,
		Name:      variant.Product.Name,
		ImageURL:  variant.Product.ImageURL,
		Price:     variant.Product.PriceAfter,
		Stock:     variant.Stock,
		SKU:       variant.Sku,
		Color:     variant.ProductColor.ColorName,
		ColorHex:  variant.ProductColor.ColorHex,
		Size:      variant.SizeCode,
	}, nil
}
