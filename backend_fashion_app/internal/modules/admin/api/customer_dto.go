package api

type CustomerListItem struct {
	ID          uint   `json:"id"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	IsActive    bool   `json:"is_active"`
	CreatedAt   string `json:"created_at"`
}

type CustomerListResponse struct {
	Items  []CustomerListItem `json:"items"`
	Total  int64              `json:"total"`
	Limit  int                `json:"limit"`
	Offset int                `json:"offset"`
}

type CustomerDetailResponse struct {
	ID          uint   `json:"id"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Role        string `json:"role"`
	IsActive    bool   `json:"is_active"`
	CreatedAt   string `json:"created_at"`
	UpdatedAt   string `json:"updated_at"`
}

type UpdateCustomerStatusRequest struct {
	IsActive bool `json:"is_active" validate:"required"`
}

type ResetCustomerPasswordRequest struct {
	NewPassword string `json:"new_password" validate:"required,min=6"`
}

