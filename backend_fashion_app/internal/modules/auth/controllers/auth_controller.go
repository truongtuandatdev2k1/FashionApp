package controllers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"gorm.io/gorm"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/config"
	"myfashion/internal/common/resp"
	"myfashion/internal/common/security"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/auth/api"
	"myfashion/internal/modules/auth/repositories"
	"myfashion/internal/modules/auth/services"
)

// AuthController xử lý các yêu cầu HTTP liên quan đến xác thực.
// @tags Auth
type AuthController struct {
	cfg                config.Config
	svc                *services.AuthService
	blacklistTokenRepo *repositories.BlacklistedTokenRepository
}

// NewAuthController khởi tạo một AuthController mới với các dependencies cần thiết.
func NewAuthController(cfg config.Config, db *gorm.DB) *AuthController {
	userRepo := repositories.NewUserRepository(db)
	rtRepo := repositories.NewRefreshTokenRepository(db)
	blacklistRepo := repositories.NewBlacklistedTokenRepository(db)
	// Sửa lỗi: Truyền đúng dependency cho AuthService.
	svc := services.NewAuthService(userRepo, rtRepo, security.BcryptHasher{})
	return &AuthController{
		cfg:                cfg,
		svc:                svc,
		blacklistTokenRepo: blacklistRepo,
	}
}

// generateAndRespondWithTokens là một hàm helper để tạo cặp access/refresh token và trả về cho client.
// Hàm này được sử dụng sau khi đăng ký hoặc đăng nhập thành công.
func (h *AuthController) generateAndRespondWithTokens(w http.ResponseWriter, r *http.Request, u *api.UserInfo) {
	accessToken, err := authn.GenerateToken(authn.JWTConfig{Secret: h.cfg.JWT_Secret, ExpiresMin: h.cfg.JWT_AccessTTLMin}, u.ID, u.Role)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to generate access token")
		return
	}

	refreshToken, err := h.svc.IssueRefreshToken(r.Context(), u.ID, h.cfg.JWT_RefreshTTLD)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to issue refresh token")
		return
	}

	resp.OK(w, api.AuthResponse{
		Token:        accessToken,
		RefreshToken: refreshToken,
		User:         u,
	})
}

// @Summary Register
// @Description Đăng ký tài khoản customer (chỉ customer, shop được cấp thủ công)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.RegisterRequest true "payload"
// @Success 201 {object} resp.Envelope{data=api.AuthResponse}
// @Failure 400 {object} resp.Envelope
// @Router /auth/register [post]
func (h *AuthController) Register(w http.ResponseWriter, r *http.Request) {
	var req api.RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	if err := validation.Validate(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, validation.GetErrorMsg(err))
		return
	}

	u, err := h.svc.RegisterCustomer(r.Context(), req.Email, req.Password, req.PhoneNumber)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	h.generateAndRespondWithTokens(w, r, &api.UserInfo{ID: u.ID, Role: string(u.Role)})
}

// @Summary Login
// @Description Đăng nhập local (email/password)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.LoginRequest true "payload"
// @Success 200 {object} resp.Envelope{data=api.AuthResponse}
// @Failure 401 {object} resp.Envelope
// @Router /auth/login [post]
func (h *AuthController) Login(w http.ResponseWriter, r *http.Request) {
	var req api.LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	u, err := h.svc.Login(r.Context(), req.Credential, req.Password)
	if err != nil {
		resp.Error(w, http.StatusUnauthorized, err.Error())
		return
	}

	h.generateAndRespondWithTokens(w, r, &api.UserInfo{ID: u.ID, Role: string(u.Role)})
}

// @Summary Refresh access token
// @Description Đổi refresh token lấy access token mới (có xoay vòng và phát hiện tái sử dụng)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.RefreshRequest true "payload"
// @Success 200 {object} resp.Envelope{data=api.AuthResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /auth/refresh [post]
func (h *AuthController) Refresh(w http.ResponseWriter, r *http.Request) {
	var req api.RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RefreshToken == "" {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}

	jwtCfg := authn.JWTConfig{Secret: h.cfg.JWT_Secret, ExpiresMin: h.cfg.JWT_AccessTTLMin}
	// Gọi service để xoay vòng token.
	user, newAccessToken, newRefreshToken, err := h.svc.RotateRefreshToken(r.Context(), req.RefreshToken, h.cfg.JWT_RefreshTTLD, jwtCfg)

	if err != nil {
		// Nếu lỗi là do token hết hạn hoặc đã bị thu hồi (dấu hiệu tấn công), trả về 401.
		if errors.Is(err, services.ErrRefreshTokenExpired) || errors.Is(err, services.ErrRefreshTokenRevoked) {
			resp.Error(w, http.StatusUnauthorized, err.Error())
		} else {
			// Các lỗi khác (ví dụ: lỗi DB) trả về 500.
			resp.Error(w, http.StatusInternalServerError, "could not refresh token")
		}
		return
	}

	// Trả về cặp token mới cho client.
	resp.OK(w, api.AuthResponse{
		Token:        newAccessToken,
		RefreshToken: newRefreshToken,
		User: &api.UserInfo{
			ID:   user.ID,
			Role: string(user.Role),
		},
	})
}

// @Summary Logout
// @Description Thu hồi tất cả refresh token và blacklist access token hiện tại
// @Security Bearer
// @Tags Auth
// @Produce json
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /auth/logout [post]
func (h *AuthController) Logout(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	// Bước 1: Thu hồi tất cả các refresh token của người dùng này trong DB.
	// Điều này đảm bảo các refresh token cũ không thể dùng để tạo access token mới.
	_ = h.svc.RevokeAllUserTokens(r.Context(), claims.UID)

	// Bước 2: Thêm access token hiện tại vào blacklist.
	// Điều này vô hiệu hóa ngay lập tức access token, không cần chờ nó hết hạn.
	if token, found := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer "); found {
		if claims.ExpiresAt.Time.After(time.Now()) {
			_ = h.blacklistTokenRepo.AddToBlacklist(token, claims.ExpiresAt.Time)
		}
	}

	resp.OK(w, "ok")
}

// @Summary Me
// @Description Lấy info hiện tại từ JWT
// @Security Bearer
// @Tags Auth
// @Produce json
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /auth/me [get]
func (h *AuthController) Me(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "no claims")
		return
	}
	resp.OK(w, map[string]any{"uid": claims.UID, "role": claims.Role})
}
