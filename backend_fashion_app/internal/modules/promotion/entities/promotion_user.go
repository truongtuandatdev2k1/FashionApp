package entities

// PromotionUser liên kết một khuyến mãi với một người dùng cụ thể.
// Bảng này được sử dụng khi TargetGroup = "specific_users".
type PromotionUser struct {
	PromotionID uint `gorm:"primaryKey;index"`
	UserID      uint `gorm:"primaryKey;index"`
}

func (PromotionUser) TableName() string {
	return "promotion_users"
}
