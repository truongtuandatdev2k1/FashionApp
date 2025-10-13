package repositories

type CustomerProfileModel struct {
	UserID    uint   `gorm:"primaryKey"`
	FullName  string `gorm:"size:255"`
	Gender    string `gorm:"size:10"`
	Birthdate string `gorm:"size:10"`
	HeightCM  int16
	WeightKG  float32
}

func (CustomerProfileModel) TableName() string { return "customer_profiles" }

type ShopProfileModel struct {
	UserID   uint   `gorm:"primaryKey"`
	ShopName string `gorm:"size:255"`
	Address  string `gorm:"size:255"`
	Phone    string `gorm:"size:32"`
}

func (ShopProfileModel) TableName() string { return "shop_profiles" }
