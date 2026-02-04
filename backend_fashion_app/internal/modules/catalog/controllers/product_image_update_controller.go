package controllers

import (
	"net/http"
	"net/url"
	"strings"

	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/catalog/api"
)

func isValidImageURL(raw string) bool {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return false
	}
	if strings.HasPrefix(raw, "/uploads/") {
		return true
	}
	u, err := url.Parse(raw)
	if err != nil {
		return false
	}
	if u.Scheme != "http" && u.Scheme != "https" {
		return false
	}
	if u.Host == "" {
		return false
	}
	return true
}

// @Summary (Admin) Update product main image
// @Description (Shop) Cập nhật ảnh đại diện của sản phẩm. Ưu tiên upload file, nếu không có file thì dùng image_url.
// @Security Bearer
// @Tags Products
// @Accept multipart/form-data
// @Produce json
// @Param id path int true "Product ID"
// @Param image formData file false "File ảnh đại diện (upload)"
// @Param image_url formData string false "URL ảnh đại diện (fallback nếu không upload file)"
// @Success 200 {object} resp.Envelope{data=api.ProductDetailResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/products/{id}/image [put]
func (c *CatalogController) AdminUpdateProductMainImage(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}

	productID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}

	if err := r.ParseMultipartForm(32 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse form data")
		return
	}

	var imgURL string
	file, header, err := r.FormFile("image")
	if err == nil {
		defer file.Close()
		if err := validation.ValidateImageFile(header); err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		savedURL, err := saveProductMainImage(file, header, productID)
		if err != nil {
			resp.Error(w, http.StatusInternalServerError, "failed to save image")
			return
		}
		imgURL = savedURL
	} else if err != http.ErrMissingFile {
		resp.Error(w, http.StatusBadRequest, "invalid image file")
		return
	} else {
		imgURL = strings.TrimSpace(r.FormValue("image_url"))
		if imgURL != "" && !isValidImageURL(imgURL) {
			resp.Error(w, http.StatusBadRequest, "invalid image_url")
			return
		}
	}

	prod, err := c.productSvc.GetProduct(r.Context(), productID)
	if err != nil || prod == nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}

	prod.ImageURL = imgURL
	if err := c.prodRepo.Update(r.Context(), prod); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	final, err := c.productSvc.GetProduct(r.Context(), productID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to fetch product")
		return
	}
	resp.OK(w, api.ToProductDetailResponse(final))
}

