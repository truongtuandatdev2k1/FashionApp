package api

type RegisterRequest struct {
	Email           string `json:"email" example:"alice@gmail.com" format:"email" validate:"required,email,gmail"`
	PhoneNumber     string `json:"phone_number" validate:"required,vn_phone"`
	Password        string `json:"password" validate:"required,password"`
	ConfirmPassword string `json:"confirmPassword" validate:"required,eqfield=Password"`
	// Role đã bị loại bỏ - chỉ cho phép đăng ký customer
}

type LoginRequest struct {
	Credential string `json:"credential"`
	Password   string `json:"password"`
}

type GoogleLoginRequest struct {
	IDToken string `json:"idToken"`
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
