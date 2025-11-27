package entities

import "time"

type ProductStats struct {
	ProductID   uint      `gorm:"primaryKey"`
	TotalStock  int       `gorm:"column:total_stock;default:0"`
	ViewCount   int       `gorm:"column:view_count;default:0"`
	SoldCount   int       `gorm:"column:sold_count;default:0"`
	RatingAvg   float64   `gorm:"column:rating_avg;type:decimal(10,2);default:0"`
	RatingCount int       `gorm:"column:rating_count;default:0"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
}

func (ProductStats) TableName() string { return "product_stats" }
