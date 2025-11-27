package validation

import (
	"fmt"
	"mime/multipart"
	"net/http"
	"path/filepath"
	"strings"
)

// AllowedImageTypes maps allowed image MIME types to their common extensions.
var AllowedImageTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/gif":  true,
}

// AllowedImageExtensions maps allowed image extensions.
var AllowedImageExtensions = map[string]bool{
	".jpg":  true,
	".jpeg": true,
	".png":  true,
	".gif":  true,
}

// ValidateImageFile checks if the uploaded file is a valid image based on its MIME type and extension.
// It returns an error if the file is not a valid or allowed image type.
func ValidateImageFile(fileHeader *multipart.FileHeader) error {
	// 1. Check file extension first as a basic filter
	ext := strings.ToLower(filepath.Ext(fileHeader.Filename))
	if !AllowedImageExtensions[ext] {
		return fmt.Errorf("invalid file extension: '%s'. Allowed extensions are: .jpg, .jpeg, .png, .gif", ext)
	}

	// 2. Open the file to check its content
	file, err := fileHeader.Open()
	if err != nil {
		return fmt.Errorf("could not open file: %w", err)
	}
	defer file.Close()

	// 3. Read the first 512 bytes to detect the MIME type
	buffer := make([]byte, 512)
	_, err = file.Read(buffer)
	if err != nil {
		return fmt.Errorf("could not read file for validation: %w", err)
	}

	// 4. Detect MIME type from the buffer
	mimeType := http.DetectContentType(buffer)

	// 5. Check if the detected MIME type is in our allowed list
	if !AllowedImageTypes[mimeType] {
		return fmt.Errorf("invalid file content type: '%s'. Only JPEG, PNG, and GIF images are allowed", mimeType)
	}

	return nil
}
