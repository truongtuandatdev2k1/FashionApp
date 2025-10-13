package api

type RegisterRequest struct {
	Email           string `json:"email" example:"alice@example.com" format:"email" validate:"required,email"`
	Password        string `json:"password" validate:"required,password"`
	ConfirmPassword string `json:"confirmPassword" validate:"required,eqfield=Password"`
	// Role đã bị loại bỏ - chỉ cho phép đăng ký customer
}
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
type GoogleLoginRequest struct {
	IDToken string `json:"idToken"`
}
type AuthResponse struct {
	Token        string `json:"token"`
	RefreshToken string `json:"refreshToken,omitempty"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refreshToken"`
}
