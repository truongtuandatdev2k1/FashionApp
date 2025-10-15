package validation

import (
	"regexp"
	"strings"

	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func init() {
	validate.RegisterValidation("password", validatePassword)
	validate.RegisterValidation("vn_phone", validateVietnamesePhone)
	validate.RegisterValidation("gmail", validateGmail)
}

// Validate validates the struct
func Validate(s interface{}) error {
	return validate.Struct(s)
}

// Custom Vietnamese phone number validation
func validateVietnamesePhone(fl validator.FieldLevel) bool {
	// Vietnamese phone number format: 10 digits, starting with 0
	vnPhoneRegex := `^0\d{9}$`
	return regexp.MustCompile(vnPhoneRegex).MatchString(fl.Field().String())
}

// Custom Gmail validation
func validateGmail(fl validator.FieldLevel) bool {
	return strings.HasSuffix(fl.Field().String(), "@gmail.com")
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

// Custom error messages
func GetErrorMsg(err error) string {
	if errs, ok := err.(validator.ValidationErrors); ok {
		for _, e := range errs {
			switch e.Tag() {
			case "required":
				return e.Field() + " is required"
			case "email":
				return "Invalid email format"
			case "gmail":
				return "Only @gmail.com emails are allowed"
			case "password":
				return "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character"
			case "eqfield":
				return e.Field() + " must match " + e.Param()
			case "vn_phone":
				return "Invalid phone number format. Must be a 10-digit Vietnamese number (e.g., 0912345678)"
			}
		}
	}
	return err.Error()
}
