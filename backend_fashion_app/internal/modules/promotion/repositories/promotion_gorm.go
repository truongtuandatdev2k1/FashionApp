package repositories

import (
	"context"
	"errors"

	"myfashion/internal/modules/promotion/entities"

	"gorm.io/gorm"
)

// PromotionRepository triển khai các phương thức truy cập dữ liệu cho Promotion
type PromotionRepository struct {
	db *gorm.DB
}

// NewPromotionRepository tạo một repository mới
func NewPromotionRepository(db *gorm.DB) *PromotionRepository {
	return &PromotionRepository{db: db}
}

// Create tạo một khuyến mãi mới và các liên kết của nó trong một transaction
func (r *PromotionRepository) Create(ctx context.Context, promotion *entities.Promotion) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 1. Tạo bản ghi promotion chính
		model := ToPromotionModel(promotion)
		if err := tx.Create(model).Error; err != nil {
			return err
		}
		promotion.ID = model.ID // Lấy lại ID vừa tạo

		// 2. Nếu là nhóm khách hàng cụ thể, thêm vào promotion_tiers
		if promotion.TargetGroup == entities.TargetCustomerTier && len(promotion.ApplicableTiers) > 0 {
			for _, tier := range promotion.ApplicableTiers {
				if err := tx.Create(&PromotionTierModel{PromotionID: model.ID, TierName: tier}).Error; err != nil {
					return err
				}
			}
		}

		// 3. Nếu là người dùng cụ thể, thêm vào promotion_users
		if promotion.TargetGroup == entities.TargetSpecificUsers && len(promotion.ApplicableUsers) > 0 {
			for _, userID := range promotion.ApplicableUsers {
				if err := tx.Create(&PromotionUserModel{PromotionID: model.ID, UserID: userID}).Error; err != nil {
					return err
				}
			}
		}

		return nil
	})
}

// FindByCode tìm một khuyến mãi theo mã, bao gồm cả thông tin tiers và users
func (r *PromotionRepository) FindByCode(ctx context.Context, code string) (*entities.Promotion, error) {
	var model PromotionModel
	if err := r.db.WithContext(ctx).Where("code = ?", code).First(&model).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, entities.ErrPromotionNotFound
		}
		return nil, err
	}

	// Lấy danh sách tiers áp dụng
	var tiers []PromotionTierModel
	var tierNames []string
	if err := r.db.WithContext(ctx).Where("promotion_id = ?", model.ID).Find(&tiers).Error; err == nil {
		for _, t := range tiers {
			tierNames = append(tierNames, t.TierName)
		}
	}

	// Lấy danh sách users áp dụng
	var users []PromotionUserModel
	var userIDs []uint
	if err := r.db.WithContext(ctx).Where("promotion_id = ?", model.ID).Find(&users).Error; err == nil {
		for _, u := range users {
			userIDs = append(userIDs, u.UserID)
		}
	}

	return ToPromotionEntity(&model, tierNames, userIDs), nil
}

// IncrementUsageCount tăng số lượt đã sử dụng của một mã khuyến mãi
func (r *PromotionRepository) IncrementUsageCount(ctx context.Context, promotionID uint, count int) error {
	return r.db.WithContext(ctx).Model(&PromotionModel{}).
		Where("id = ?", promotionID).
		UpdateColumn("usage_count", gorm.Expr("usage_count + ?", count)).Error
}
