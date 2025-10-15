package controllers

import (
	"encoding/json"
	"net/http"

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

// @tags Auth
type AuthController struct {
	cfg config.Config
	svc *services.AuthService
}

func NewAuthController(cfg config.Config, db *gorm.DB) *AuthController {
	repo := repositories.NewUserRepository(db)
	rtrepo := repositories.NewRefreshTokenRepository(db)
	svc := services.NewAuthService(repo, rtrepo, security.BcryptHasher{})
	return &AuthController{cfg: cfg, svc: svc}
}

// @Summary Register
// @Description Đăng ký tài khoản customer (chỉ customer, shop được cấp thủ công)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.RegisterRequest true "payload"
// @Success 201 {object} resp.Envelope
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
	j, _ := authn.GenerateToken(authn.JWTConfig{Secret: h.cfg.JWT_Secret, ExpiresMin: h.cfg.JWT_AccessTTLMin}, u.ID, string(u.Role))
	rtPlain, _ := security.GenerateRandomToken(32)
	_, _ = h.svc.IssueRefreshToken(r.Context(), u.ID, h.cfg.JWT_RefreshTTLD, rtPlain)
	resp.Created(w, api.AuthResponse{
		Token:        j,
		RefreshToken: rtPlain,
		User: &api.UserInfo{
			ID:   u.ID,
			Role: string(u.Role),
		},
	})
}

// @Summary Login
// @Description Đăng nhập local (email/password)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.LoginRequest true "payload"
// @Success 200 {object} resp.Envelope
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
	j, _ := authn.GenerateToken(authn.JWTConfig{Secret: h.cfg.JWT_Secret, ExpiresMin: h.cfg.JWT_AccessTTLMin}, u.ID, string(u.Role))
	rtPlain, _ := security.GenerateRandomToken(32)
	_, _ = h.svc.IssueRefreshToken(r.Context(), u.ID, h.cfg.JWT_RefreshTTLD, rtPlain)
	resp.OK(w, api.AuthResponse{
		Token:        j,
		RefreshToken: rtPlain,
		User: &api.UserInfo{
			ID:   u.ID,
			Role: string(u.Role),
		},
	})
}

// @Summary Login Google
// @Description Xác thực Google ID Token; nếu chưa có user thì tạo (role=customer)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.GoogleLoginRequest true "payload"
// @Success 200 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Router /auth/google [post]
func (h *AuthController) Google(w http.ResponseWriter, r *http.Request) {
	var req api.GoogleLoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	u, err := h.svc.LoginGoogle(r.Context(), req.IDToken, h.cfg.GoogleClientID)
	if err != nil {
		resp.Error(w, http.StatusUnauthorized, err.Error())
		return
	}
	j, _ := authn.GenerateToken(authn.JWTConfig{Secret: h.cfg.JWT_Secret, ExpiresMin: h.cfg.JWT_AccessTTLMin}, u.ID, string(u.Role))
	rtPlain, _ := security.GenerateRandomToken(32)
	_, _ = h.svc.IssueRefreshToken(r.Context(), u.ID, h.cfg.JWT_RefreshTTLD, rtPlain)
	resp.OK(w, api.AuthResponse{
		Token:        j,
		RefreshToken: rtPlain,
		User: &api.UserInfo{
			ID:   u.ID,
			Role: string(u.Role),
		},
	})
}

// @Summary Refresh access token
// @Description Đổi refresh token lấy access token mới (rotate)
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body api.RefreshRequest true "payload"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Router /auth/refresh [post]
func (h *AuthController) Refresh(w http.ResponseWriter, r *http.Request) {
	var req api.RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RefreshToken == "" {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	// Rotate refresh token
	newRT, _ := security.GenerateRandomToken(32)
	rt, err := h.svc.VerifyAndRotateRefreshToken(r.Context(), req.RefreshToken, newRT, h.cfg.JWT_RefreshTTLD)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	// Issue new access token for the same user
	j, _ := authn.GenerateToken(authn.JWTConfig{Secret: h.cfg.JWT_Secret, ExpiresMin: h.cfg.JWT_AccessTTLMin}, rt.UserID, "")
	resp.OK(w, api.AuthResponse{Token: j, RefreshToken: newRT})
}

// @Summary Logout
// @Description Thu hồi tất cả refresh token của người dùng hiện tại
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
	_ = h.svc.RevokeAllUserTokens(r.Context(), claims.UID)
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
