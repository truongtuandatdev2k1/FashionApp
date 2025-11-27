package entities

type CustomerProfile struct {
	UserID   uint   `gorm:"primaryKey"`
	FullName string `gorm:"type:varchar(255)"`
	Age      int    `gorm:"type:int"`
	Gender   string `gorm:"type:varchar(10)"`
	Address  string `gorm:"type:text"`
	Tier     string `gorm:"type:varchar(20);default:'bronze'"` // Hạng thành viên: bronze, silver, gold
	ImgURL   string `gorm:"column:img_url;type:varchar(255)"`
}

func (CustomerProfile) TableName() string {
	return "customer_profiles"
}
