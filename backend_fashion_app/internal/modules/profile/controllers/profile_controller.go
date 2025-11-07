package controllers

import (
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"gorm.io/gorm"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/profile/api"
	"myfashion/internal/modules/profile/entities"
	"myfashion/internal/modules/profile/repositories"
	"myfashion/internal/modules/profile/services"
)

// @tags Profile
type ProfileController struct {
	svc *services.ProfileService
}

func NewProfileController(db *gorm.DB) *ProfileController {
	cRepo := repositories.NewCustomerRepo(db)
	sRepo := repositories.NewShopRepo(db)
	return &ProfileController{svc: services.NewProfileService(cRepo, sRepo)}
}

// saveAvatarFile lưu file avatar được tải lên và trả về đường dẫn
func (h *ProfileController) saveAvatarFile(file *multipart.FileHeader) (string, error) {
	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	uploadDir := "uploads/avatars"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return "", err
	}

	dstPath := filepath.Join(uploadDir, filename)
	dst, err := os.Create(dstPath)
	if err != nil {
		return "", err
	}
	defer dst.Close()

	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}

	return "/" + uploadDir + "/" + filename, nil
}

// GET /profiles/me
// @Summary Get my profile
// @Security Bearer
// @Tags Profile
// @Produce json
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /profiles/me [get]
func (h *ProfileController) GetMine(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	data, err := h.svc.GetMine(r.Context(), claims.Role, claims.UID)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.OK(w, data)
}

// PUT /profiles/me
// @Summary Upsert my profile
// @Description Tạo hoặc cập nhật hồ sơ. Hỗ trợ upload avatar qua file (multipart/form-data) hoặc URL (form field).
// @Security Bearer
// @Tags Profile
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string false "(Customer) Tên đầy đủ"
// @Param age formData int false "(Customer) Tuổi"
// @Param gender formData string false "(Customer) Giới tính"
// @Param address formData string false "Địa chỉ (chung cho Customer và Shop)"
// @Param shop_name formData string false "(Shop) Tên cửa hàng"
// @Param avatar formData file false "File ảnh avatar để tải lên"
// @Param img_url formData string false "URL ảnh avatar (nếu không tải file)"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /profiles/me [put]
func (h *ProfileController) UpsertMine(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	// Parse multipart form, 32MB max memory
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		resp.Error(w, http.StatusBadRequest, "failed to parse form data")
		return
	}

	// Xử lý upload ảnh (nếu có)
	var imgURL string
	file, header, err := r.FormFile("avatar")
	if err == nil {
		defer file.Close()
		savedURL, err := h.saveAvatarFile(header)
		if err != nil {
			resp.Error(w, http.StatusInternalServerError, "failed to save avatar file")
			return
		}
		imgURL = savedURL
	} else if err != http.ErrMissingFile {
		// Nếu có lỗi khác ngoài việc không có file, báo lỗi
		resp.Error(w, http.StatusBadRequest, "invalid avatar file")
		return
	} else {
		// Nếu không có file, lấy giá trị từ trường img_url
		imgURL = r.FormValue("img_url")
	}

	switch claims.Role {
	case "customer":
		age, _ := strconv.Atoi(r.FormValue("age"))
		customerData := &api.CustomerUpsert{
			FullName: r.FormValue("full_name"),
			Age:      age,
			Gender:   r.FormValue("gender"),
			Address:  r.FormValue("address"),
			ImgURL:   imgURL,
		}

		if err := validation.Validate(customerData); err != nil {
			resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
			return
		}

		err := h.svc.UpsertMine(r.Context(), claims.Role, claims.UID, &entities.CustomerProfile{
			FullName: customerData.FullName,
			Age:      customerData.Age,
			Gender:   customerData.Gender,
			Address:  customerData.Address,
			ImgURL:   customerData.ImgURL,
		})
		if err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		resp.OK(w, "ok")

	case "shop":
		shopData := &api.ShopUpsert{
			ShopName: r.FormValue("shop_name"),
			Address:  r.FormValue("address"),
			ImgURL:   imgURL,
		}

		if err := validation.Validate(shopData); err != nil {
			resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
			return
		}

		err := h.svc.UpsertMine(r.Context(), claims.Role, claims.UID, &entities.ShopProfile{
			ShopName: shopData.ShopName,
			Address:  shopData.Address,
			ImgURL:   shopData.ImgURL,
		})
		if err != nil {
			resp.Error(w, http.StatusBadRequest, err.Error())
			return
		}
		resp.OK(w, "ok")

	default:
		resp.Error(w, http.StatusBadRequest, "unsupported role")
	}
}
