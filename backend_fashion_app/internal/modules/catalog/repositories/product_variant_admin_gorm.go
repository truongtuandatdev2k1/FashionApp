package repositories

import (
	"context"

	"gorm.io/gorm"
)

type VariantAdminRow struct {
	VariantID      uint
	ProductID      uint
	ProductColorID uint
	ColorHex       string
	ColorName      string
	SizeCode       string
	Stock          int
	Sku            string
	CreatedAt      int64
	UpdatedAt      int64
}

type ProductVariantAdminRepo struct{ db *gorm.DB }

func NewProductVariantAdminRepo(db *gorm.DB) *ProductVariantAdminRepo {
	return &ProductVariantAdminRepo{db: db}
}

func (r *ProductVariantAdminRepo) ListByProductID(ctx context.Context, productID uint) ([]ProductVariantModel, []ProductColorModel, error) {
	// We'll query variants preloading color
	var vars []ProductVariantModel
	if err := r.db.WithContext(ctx).
		Preload("ProductColor").
		Where("product_id = ?", productID).
		Order("id DESC").
		Find(&vars).Error; err != nil {
		return nil, nil, err
	}
	return vars, nil, nil
}

func (r *ProductVariantAdminRepo) GetByID(ctx context.Context, variantID uint) (*ProductVariantModel, error) {
	var v ProductVariantModel
	if err := r.db.WithContext(ctx).Preload("ProductColor").Where("id = ?", variantID).First(&v).Error; err != nil {
		return nil, err
	}
	return &v, nil
}

func (r *ProductVariantAdminRepo) UpdateStock(ctx context.Context, variantID uint, stock int) (productID uint, totalStock int, err error) {
	var v ProductVariantModel
	if err := r.db.WithContext(ctx).Where("id = ?", variantID).First(&v).Error; err != nil {
		return 0, 0, err
	}
	productID = v.ProductID

	if err := r.db.WithContext(ctx).Model(&ProductVariantModel{}).Where("id = ?", variantID).Update("stock", stock).Error; err != nil {
		return 0, 0, err
	}
	var sum int64
	if err := r.db.WithContext(ctx).Model(&ProductVariantModel{}).Where("product_id = ?", productID).Select("COALESCE(SUM(stock),0)").Scan(&sum).Error; err != nil {
		return productID, 0, err
	}
	return productID, int(sum), nil
}

func (r *ProductVariantAdminRepo) UpdateSku(ctx context.Context, variantID uint, sku string) (productID uint, err error) {
	var v ProductVariantModel
	if err := r.db.WithContext(ctx).Where("id = ?", variantID).First(&v).Error; err != nil {
		return 0, err
	}
	productID = v.ProductID
	if err := r.db.WithContext(ctx).Model(&ProductVariantModel{}).Where("id = ?", variantID).Update("sku", sku).Error; err != nil {
		return productID, err
	}
	return productID, nil
}

