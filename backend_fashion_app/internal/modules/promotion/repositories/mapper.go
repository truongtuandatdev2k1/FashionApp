package repositories

import (
	"myfashion/internal/modules/promotion/entities"
)

// ToPromotionEntity converts PromotionModel to Promotion entity
func ToPromotionEntity(m *PromotionModel, tiers []string, users []uint) *entities.Promotion {
	return &entities.Promotion{
		ID:              m.ID,
		Code:            m.Code,
		Name:            m.Name,
		Description:     m.Description,
		Type:            entities.PromotionType(m.Type),
		Value:           m.Value,
		MaxDiscount:     m.MaxDiscount,
		MinOrderValue:   m.MinOrderValue,
		StartDate:       m.StartDate,
		EndDate:         m.EndDate,
		UsageLimit:      m.UsageLimit,
		UsageCount:      m.UsageCount,
		UserUsageLimit:  m.UserUsageLimit,
		IsActive:        m.IsActive,
		IsStackable:     m.IsStackable,
		TargetGroup:     entities.TargetGroup(m.TargetGroup),
		ApplicableTiers: tiers,
		ApplicableUsers: users,
		CreatedAt:       m.CreatedAt,
		UpdatedAt:       m.UpdatedAt,
	}
}

// ToPromotionModel converts Promotion entity to PromotionModel
func ToPromotionModel(e *entities.Promotion) *PromotionModel {
	return &PromotionModel{
		ID:             e.ID,
		Code:           e.Code,
		Name:           e.Name,
		Description:    e.Description,
		Type:           string(e.Type),
		Value:          e.Value,
		MaxDiscount:    e.MaxDiscount,
		MinOrderValue:  e.MinOrderValue,
		StartDate:      e.StartDate,
		EndDate:        e.EndDate,
		UsageLimit:     e.UsageLimit,
		UsageCount:     e.UsageCount,
		UserUsageLimit: e.UserUsageLimit,
		IsActive:       e.IsActive,
		IsStackable:    e.IsStackable,
		TargetGroup:    string(e.TargetGroup),
	}
}
