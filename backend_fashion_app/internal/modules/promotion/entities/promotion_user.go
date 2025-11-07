package entities

// PromotionUser liên kết một khuyến mãi với một người dùng cụ thể.
// Bảng này được sử dụng khi TargetGroup = "specific_users".
type PromotionUser struct {
	PromotionID uint `gorm:"primaryKey"`
	UserID      uint `gorm:"primaryKey"`
}
