package api

type RegisterRequest struct {
	Email           string `json:"email" example:"alice@example.com" format:"email" validate:"required,email"`
	PhoneNumber     string `json:"phone_number" validate:"required,vn_phone"`
	Password        string `json:"password" validate:"required,password"`
	ConfirmPassword string `json:"confirmPassword" validate:"required,eqfield=Password"`
	// Role đã bị loại bỏ - chỉ cho phép đăng ký customer
}

type LoginRequest struct {
	Credential string `json:"credential" example:"test@example.com" validate:"required,email,gmail"`
	Password   string `json:"password" example:"Cong123@" validate:"required,password"`
}

// UserInfo holds basic user information.
type UserInfo struct {
	ID   uint   `json:"id"`
	Role string `json:"role"`
}

type AuthResponse struct {
	Token        string    `json:"token"`
	RefreshToken string    `json:"refreshToken,omitempty"`
	User         *UserInfo `json:"user,omitempty"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refreshToken"`
}
