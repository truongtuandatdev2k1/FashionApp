package api

type CustomerUpsert struct {
	FullName  string  `json:"full_name"`
	Gender    string  `json:"gender"`
	Birthdate string  `json:"birthdate"`
	HeightCM  int16   `json:"height_cm"`
	WeightKG  float32 `json:"weight_kg"`
}

type ShopUpsert struct {
	ShopName string `json:"shop_name"`
	Address  string `json:"address"`
	Phone    string `json:"phone"`
}
