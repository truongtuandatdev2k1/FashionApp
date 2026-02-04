package repositories

import "time"

type ProductSimilarityModel struct {
	ProductID         uint      `gorm:"primaryKey"`
	SimilarProductID  uint      `gorm:"primaryKey"`
	Score             float64   `gorm:"not null;index:idx_score"`
	Source            string    `gorm:"type:varchar(50);not null;index:idx_source"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime"`
}

func (ProductSimilarityModel) TableName() string {
	return "product_similarities"
}
