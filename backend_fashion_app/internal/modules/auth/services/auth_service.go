package services

import (
	"context"
	"errors"
	"time"

	"myfashion/internal/common/security"
	"myfashion/internal/modules/auth/entities"

	"google.golang.org/api/idtoken"
)

type AuthService struct {
	repo   UserRepository
	tokens RefreshTokenRepository
	pwd    security.PasswordHasher
}

func NewAuthService(repo UserRepository, tokens RefreshTokenRepository, pwd security.PasswordHasher) *AuthService {
	return &AuthService{repo: repo, tokens: tokens, pwd: pwd}
}

// RegisterCustomer đăng ký tài khoản customer (shop được cấp thủ công)
func (s *AuthService) RegisterCustomer(ctx context.Context, email, rawPwd string) (*entities.User, error) {
	if ex, _ := s.repo.GetByEmail(ctx, email); ex != nil {
		return nil, errors.New("email already exists")
	}
	hash, err := s.pwd.Hash(rawPwd)
	if err != nil {
		return nil, err
	}
	// Chỉ tạo tài khoản customer, GoogleSub = nil cho local account
	u := &entities.User{Email: email, Password: hash, Role: entities.RoleCustomer, Provider: entities.ProviderLocal, GoogleSub: nil}
	if err := s.repo.Create(ctx, u); err != nil {
		return nil, err
	}
	return u, nil
}

// Register (deprecated) - giữ lại để tương thích, nhưng chỉ cho phép customer
func (s *AuthService) Register(ctx context.Context, email, rawPwd string, role entities.Role) (*entities.User, error) {
	// Bỏ qua role được truyền vào, luôn tạo customer
	return s.RegisterCustomer(ctx, email, rawPwd)
}

func (s *AuthService) Login(ctx context.Context, email, rawPwd string) (*entities.User, error) {
	u, err := s.repo.GetByEmail(ctx, email)
	if err != nil || u == nil {
		return nil, errors.New("invalid credentials")
	}
	if u.Provider != entities.ProviderLocal {
		return nil, errors.New("account is not local")
	}
	if !s.pwd.Verify(u.Password, rawPwd) {
		return nil, errors.New("invalid credentials")
	}
	return u, nil
}

func (s *AuthService) LoginGoogle(ctx context.Context, idToken, audienceClientID string) (*entities.User, error) {
	payload, err := idtoken.Validate(ctx, idToken, audienceClientID)
	if err != nil {
		return nil, errors.New("invalid google token")
	}
	email, _ := payload.Claims["email"].(string)
	sub, _ := payload.Claims["sub"].(string)
	if email == "" || sub == "" {
		return nil, errors.New("google token missing claims")
	}

	if u, err := s.repo.GetByGoogleSub(ctx, sub); err != nil {
		return nil, err
	} else if u != nil {
		return u, nil
	}
	if u, _ := s.repo.GetByEmail(ctx, email); u != nil {
		u.Provider = entities.ProviderGoogle
		u.GoogleSub = &sub
		return u, nil // demo: skip DB update for speed
	}
	u := &entities.User{Email: email, Role: entities.RoleCustomer, Provider: entities.ProviderGoogle, GoogleSub: &sub}
	if err := s.repo.Create(ctx, u); err != nil {
		return nil, err
	}
	return u, nil
}

func (s *AuthService) IssueRefreshToken(ctx context.Context, userID uint, ttlDays int, tokenPlain string) (*entities.RefreshToken, error) {
	rt := &entities.RefreshToken{
		UserID:    userID,
		TokenHash: security.HashTokenSHA256(tokenPlain),
		ExpiresAt: time.Now().Add(time.Duration(ttlDays) * 24 * time.Hour),
		Revoked:   false,
	}
	if err := s.tokens.Create(ctx, rt); err != nil {
		return nil, err
	}
	return rt, nil
}

func (s *AuthService) VerifyAndRotateRefreshToken(ctx context.Context, tokenPlain string, newTokenPlain string, ttlDays int) (*entities.RefreshToken, error) {
	hash := security.HashTokenSHA256(tokenPlain)
	found, err := s.tokens.GetByHash(ctx, hash)
	if err != nil || found == nil {
		return nil, errors.New("invalid refresh token")
	}
	if found.Revoked || time.Now().After(found.ExpiresAt) {
		return nil, errors.New("refresh token expired or revoked")
	}
	// revoke old and create new
	if err := s.tokens.RevokeByHash(ctx, hash); err != nil {
		return nil, err
	}
	return s.IssueRefreshToken(ctx, found.UserID, ttlDays, newTokenPlain)
}

func (s *AuthService) RevokeAllUserTokens(ctx context.Context, userID uint) error {
	return s.tokens.RevokeAllByUser(ctx, userID)
}
