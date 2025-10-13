package validation

import (
	"regexp"

	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func init() {
	validate.RegisterValidation("password", validatePassword)
}

// Validate validates the struct
func Validate(s interface{}) error {
	return validate.Struct(s)
}

// Custom password validation
func validatePassword(fl validator.FieldLevel) bool {
	password := fl.Field().String()
	if len(password) < 8 {
		return false
	}
	// Phải chứa ít nhất một chữ hoa, một chữ thường, một số và một ký tự đặc biệt
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(password)
	hasLower := regexp.MustCompile(`[a-z]`).MatchString(password)
	hasNumber := regexp.MustCompile(`[0-9]`).MatchString(password)
	hasSpecial := regexp.MustCompile(`[!@#$%^&*(),.?":{}|<>]`).MatchString(password)

	return hasUpper && hasLower && hasNumber && hasSpecial
}

// Custom error messages (optional, can be expanded)
func GetErrorMsg(err error) string {
	if errs, ok := err.(validator.ValidationErrors); ok {
		for _, e := range errs {
			switch e.Tag() {
			case "required":
				return e.Field() + " is required"
			case "email":
				return "Invalid email format"
			case "password":
				return "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character"
			case "eqfield":
				return e.Field() + " must match " + e.Param()
			}
		}
	}
	return err.Error()
}
