package repositories

import (
	"context"
	"errors"
	"myfashion/internal/modules/cart/entities"

	"gorm.io/gorm"
)

type CartGormRepo struct {
	db *gorm.DB
}

func NewCartGormRepo(db *gorm.DB) *CartGormRepo {
	return &CartGormRepo{db: db}
}

// ========== Cart Methods ==========

// GetOrCreateCartByUserID lấy hoặc tạo giỏ hàng cho user
func (r *CartGormRepo) GetOrCreateCartByUserID(ctx context.Context, userID uint) (*entities.Cart, error) {
	var model CartModel

	// Tìm giỏ hàng hiện có
	err := r.db.WithContext(ctx).Where("user_id = ?", userID).First(&model).Error

	if err == nil {
		// Giỏ hàng đã tồn tại
		return ToCartEntity(&model), nil
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		// Lỗi khác ngoài "không tìm thấy"
		return nil, err
	}

	// Tạo giỏ hàng mới
	model = CartModel{UserID: userID}
	if err := r.db.WithContext(ctx).Create(&model).Error; err != nil {
		return nil, err
	}

	return ToCartEntity(&model), nil
}

// GetCartByUserID lấy giỏ hàng của user (không tạo mới)
func (r *CartGormRepo) GetCartByUserID(ctx context.Context, userID uint) (*entities.Cart, error) {
	var model CartModel
	err := r.db.WithContext(ctx).Where("user_id = ?", userID).First(&model).Error
	if err != nil {
		return nil, err
	}
	return ToCartEntity(&model), nil
}

// ClearCart xóa tất cả items trong giỏ hàng
func (r *CartGormRepo) ClearCart(ctx context.Context, cartID uint) error {
	return r.db.WithContext(ctx).Where("cart_id = ?", cartID).Delete(&CartItemModel{}).Error
}

// ========== CartItem Methods ==========

// FindItemByCartAndProduct tìm item trong giỏ hàng theo productID
func (r *CartGormRepo) FindItemByCartAndProduct(ctx context.Context, cartID, productID uint) (*entities.CartItem, error) {
	var model CartItemModel
	err := r.db.WithContext(ctx).
		Where("cart_id = ? AND product_id = ?", cartID, productID).
		First(&model).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil // Không tìm thấy -> trả về nil, không phải lỗi
		}
		return nil, err
	}

	return ToCartItemEntity(&model), nil
}

// FindItemByID tìm item theo ID
func (r *CartGormRepo) FindItemByID(ctx context.Context, itemID uint) (*entities.CartItem, error) {
	var model CartItemModel
	err := r.db.WithContext(ctx).First(&model, itemID).Error
	if err != nil {
		return nil, err
	}
	return ToCartItemEntity(&model), nil
}

// CreateItem tạo item mới trong giỏ hàng
func (r *CartGormRepo) CreateItem(ctx context.Context, item *entities.CartItem) error {
	model := ToCartItemModel(item)
	if err := r.db.WithContext(ctx).Create(model).Error; err != nil {
		return err
	}
	item.ID = model.ID
	item.CreatedAt = model.CreatedAt
	item.UpdatedAt = model.UpdatedAt
	return nil
}

// UpdateItem cập nhật item trong giỏ hàng
func (r *CartGormRepo) UpdateItem(ctx context.Context, item *entities.CartItem) error {
	model := ToCartItemModel(item)
	return r.db.WithContext(ctx).Save(model).Error
}

// DeleteItem xóa item khỏi giỏ hàng
func (r *CartGormRepo) DeleteItem(ctx context.Context, itemID uint) error {
	return r.db.WithContext(ctx).Delete(&CartItemModel{}, itemID).Error
}

// GetItemsByCartID lấy tất cả items trong giỏ hàng
func (r *CartGormRepo) GetItemsByCartID(ctx context.Context, cartID uint) ([]entities.CartItem, error) {
	var models []CartItemModel
	err := r.db.WithContext(ctx).
		Where("cart_id = ?", cartID).
		Order("created_at DESC").
		Find(&models).Error

	if err != nil {
		return nil, err
	}

	items := make([]entities.CartItem, len(models))
	for i, m := range models {
		items[i] = *ToCartItemEntity(&m)
	}

	return items, nil
}
