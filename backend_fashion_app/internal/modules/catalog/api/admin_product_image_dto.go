package api

// AdminProductImageUpdateRequest dùng cho endpoint cập nhật ảnh đại diện sản phẩm
type AdminProductImageUpdateRequest struct {
	ImageURL string `json:"image_url"` // Nếu không upload file, có thể truyền URL
}

// AdminProductColorImageAddRequest dùng cho endpoint thêm ảnh theo màu
type AdminProductColorImageAddRequest struct {
	ImageURLs []string `json:"image_urls"` // Danh sách URL ảnh mới (append)
}

// AdminProductColorImageDeleteRequest dùng cho endpoint xóa 1 ảnh theo màu
type AdminProductColorImageDeleteRequest struct {
	ImageID uint `json:"image_id"` // ID của ảnh cần xóa
}
