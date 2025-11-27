package services

import (
	"context"
	"errors"
	"time"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/security"
	"myfashion/internal/modules/auth/entities"
	"myfashion/internal/modules/auth/repositories"
)

var (
	// ErrRefreshTokenExpired là lỗi trả về khi refresh token đã hết hạn.
	ErrRefreshTokenExpired = errors.New("refresh token has expired")
	// ErrRefreshTokenRevoked là lỗi trả về khi refresh token đã bị thu hồi hoặc đang bị tái sử dụng.
	ErrRefreshTokenRevoked = errors.New("refresh token has been revoked or reused")
)

// AuthService chứa logic nghiệp vụ cho việc xác thực người dùng.
type AuthService struct {
	repo   *repositories.UserRepository
	tokens *repositories.RefreshTokenRepository
	pwd    security.PasswordHasher
}

// NewAuthService tạo một instance mới của AuthService.
func NewAuthService(repo *repositories.UserRepository, tokens *repositories.RefreshTokenRepository, pwd security.PasswordHasher) *AuthService {
	return &AuthService{repo: repo, tokens: tokens, pwd: pwd}
}

// RegisterCustomer đăng ký một tài khoản customer mới.
func (s *AuthService) RegisterCustomer(ctx context.Context, email, rawPwd, phoneNumber string) (*entities.User, error) {
	if ex, _ := s.repo.GetByEmail(ctx, email); ex != nil {
		return nil, errors.New("email already exists")
	}
	if ex, _ := s.repo.GetByPhone(ctx, phoneNumber); ex != nil {
		return nil, errors.New("phone number already exists")
	}
	hash, err := s.pwd.Hash(rawPwd)
	if err != nil {
		return nil, err
	}
	u := &entities.User{Email: email, Password: hash, PhoneNumber: phoneNumber, Role: entities.RoleCustomer}
	if err := s.repo.Create(ctx, u); err != nil {
		return nil, err
	}
	return u, nil
}

// Login xử lý đăng nhập local bằng email/số điện thoại và mật khẩu.
func (s *AuthService) Login(ctx context.Context, credential, rawPwd string) (*entities.User, error) {
	u, err := s.repo.GetByCredential(ctx, credential)
	if err != nil || u == nil {
		return nil, errors.New("invalid credentials")
	}
	if !s.pwd.Verify(u.Password, rawPwd) {
		return nil, errors.New("invalid credentials")
	}
	return u, nil
}

// IssueRefreshToken tạo một refresh token mới và lưu vào DB.
// Hàm này thường được gọi sau khi đăng nhập thành công.
// Trả về token dưới dạng plaintext để gửi cho client.
func (s *AuthService) IssueRefreshToken(ctx context.Context, userID uint, ttlDays int) (string, error) {
	tokenPlain, err := security.GenerateRandomToken(32)
	if err != nil {
		return "", err
	}

	rt := &entities.RefreshToken{
		UserID:    userID,
		TokenHash: security.HashTokenSHA256(tokenPlain),
		ExpiresAt: time.Now().Add(time.Duration(ttlDays) * 24 * time.Hour),
	}

	if err := s.tokens.Create(ctx, rt); err != nil {
		return "", err
	}
	return tokenPlain, nil
}

// RotateRefreshToken thực hiện xoay vòng refresh token một cách an toàn.
// Nó vô hiệu hóa token cũ, tạo token mới, và có cơ chế phát hiện tái sử dụng token.
func (s *AuthService) RotateRefreshToken(ctx context.Context, oldTokenPlain string, ttlDays int, jwtCfg authn.JWTConfig) (*entities.User, string, string, error) {
	oldTokenHash := security.HashTokenSHA256(oldTokenPlain)
	oldToken, err := s.tokens.GetByHash(ctx, oldTokenHash)
	if err != nil {
		return nil, "", "", err // Lỗi DB
	}
	// Nếu không tìm thấy token, có thể nó đã bị thu hồi do tấn công, hoặc là token giả.
	if oldToken == nil {
		return nil, "", "", ErrRefreshTokenRevoked
	}

	// **Cơ chế 1: Phát hiện Tái sử dụng (Reuse Detection)**
	// Nếu token đã bị thu hồi (RevokedAt != nil), đây là dấu hiệu của việc token đã bị rò rỉ.
	if oldToken.RevokedAt != nil {
		// Hành động bảo mật: Thu hồi toàn bộ "gia đình" token bắt nguồn từ token bị rò rỉ này.
		if oldToken.ReplacedByTokenHash != nil {
			_ = s.tokens.RevokeDescendants(ctx, *oldToken.ReplacedByTokenHash)
		}
		return nil, "", "", ErrRefreshTokenRevoked
	}

	// Kiểm tra xem token có hết hạn hay không.
	if time.Now().After(oldToken.ExpiresAt) {
		return nil, "", "", ErrRefreshTokenExpired
	}

	// --- Bắt đầu quá trình Xoay vòng (Rotation) ---

	// 1. Lấy thông tin người dùng để tạo access token mới.
	user, err := s.GetUserByID(ctx, oldToken.UserID)
	if err != nil {
		return nil, "", "", err
	}

	// 2. Tạo một refresh token mới hoàn toàn.
	newRefreshTokenPlain, err := s.IssueRefreshToken(ctx, user.ID, ttlDays)
	if err != nil {
		return nil, "", "", err
	}
	newRefreshTokenHash := security.HashTokenSHA256(newRefreshTokenPlain)

	// 3. Thu hồi token cũ và ghi nhận nó đã được thay thế bởi token mới.
	now := time.Now()
	oldToken.RevokedAt = &now
	oldToken.ReplacedByTokenHash = &newRefreshTokenHash
	if err := s.tokens.Save(ctx, oldToken); err != nil {
		return nil, "", "", err
	}

	// 4. Tạo access token mới tương ứng.
	newAccessToken, err := authn.GenerateToken(jwtCfg, user.ID, string(user.Role))
	if err != nil {
		return nil, "", "", err
	}

	return user, newAccessToken, newRefreshTokenPlain, nil
}

// RevokeAllUserTokens thu hồi tất cả các refresh token đang hoạt động của một người dùng.
// Thường được sử dụng cho chức năng "Đăng xuất khỏi tất cả các thiết bị".
func (s *AuthService) RevokeAllUserTokens(ctx context.Context, userID uint) error {
	return s.tokens.RevokeAllByUser(ctx, userID)
}

// GetUserByID lấy thông tin người dùng bằng ID.
func (s *AuthService) GetUserByID(ctx context.Context, userID uint) (*entities.User, error) {
	return s.repo.GetByID(ctx, userID)
}
