package entities

// PromotionTier liên kết một khuyến mãi với một hạng thành viên cụ thể.
// Bảng này được sử dụng khi TargetGroup = "customer_tier".
type PromotionTier struct {
	PromotionID uint   `gorm:"primaryKey"`
	TierName    string `gorm:"primaryKey;size:50"` // Ví dụ: "bronze", "silver", "gold"
}
