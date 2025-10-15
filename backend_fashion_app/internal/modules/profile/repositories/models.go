package repositories

type CustomerProfileModel struct {
	UserID   uint   `gorm:"primaryKey"`
	FullName string `gorm:"size:255"`
	Age      int
	Gender   string `gorm:"size:10"`
	Address  string `gorm:"size:255"`
}

func (CustomerProfileModel) TableName() string { return "customer_profiles" }

type ShopProfileModel struct {
	UserID   uint   `gorm:"primaryKey"`
	ShopName string `gorm:"size:255"`
	Address  string `gorm:"size:255"`
}

func (ShopProfileModel) TableName() string { return "shop_profiles" }
