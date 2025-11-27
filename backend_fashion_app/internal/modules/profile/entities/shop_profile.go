package entities

type ShopProfile struct {
	UserID   uint   `gorm:"primaryKey"`
	ShopName string `gorm:"type:varchar(255)"`
	Address  string `gorm:"type:text"`
	ImgURL   string `gorm:"column:img_url;type:varchar(255)"`
}

func (ShopProfile) TableName() string {
	return "shop_profiles"
}
