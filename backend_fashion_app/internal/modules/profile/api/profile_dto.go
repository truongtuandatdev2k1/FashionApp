package api

type CustomerUpsert struct {
	FullName string `json:"full_name" validate:"required"`
	Age      int    `json:"age" validate:"required,gt=0"`
	Gender   string `json:"gender" validate:"required"`
	Address  string `json:"address" validate:"required"`
	ImgURL   string `json:"img_url,omitempty"`
}

type ShopUpsert struct {
	ShopName string `json:"shop_name" validate:"required"`
	Address  string `json:"address" validate:"required"`
	ImgURL   string `json:"img_url,omitempty"`
}

// UpsertProfileRequest is a unified request body for the profile upsert endpoint.
// Only one of the fields (Customer or Shop) should be provided, depending on the user's role.
type UpsertProfileRequest struct {
	Customer *CustomerUpsert `json:"customer,omitempty"`
	Shop     *ShopUpsert     `json:"shop,omitempty"`
}
