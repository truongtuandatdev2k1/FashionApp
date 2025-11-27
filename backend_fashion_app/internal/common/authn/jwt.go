package authn

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Claims struct {
	UID  uint   `json:"uid"`
	Role string `json:"role"`
	jwt.RegisteredClaims
}

type JWTConfig struct {
	Secret     string
	ExpiresMin int
}

func GenerateToken(cfg JWTConfig, uid uint, role string) (string, error) {
	now := time.Now()
	claims := Claims{
		UID:  uid,
		Role: role,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(time.Duration(cfg.ExpiresMin) * time.Minute)),
		},
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(cfg.Secret))
}

type ctxKey string

const claimsKey ctxKey = "claims"

func GetClaims(ctx context.Context) *Claims {
	if v := ctx.Value(claimsKey); v != nil {
		if c, ok := v.(*Claims); ok {
			return c
		}
	}
	return nil
}

// BlacklistChecker interface để kiểm tra token blacklist
type BlacklistChecker interface {
	IsBlacklisted(token string) (bool, error)
}

func AuthRequired(secret string) func(http.Handler) http.Handler {
	return AuthRequiredWithBlacklist(secret, nil)
}

func AuthRequiredWithBlacklist(secret string, blacklistChecker BlacklistChecker) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			auth := r.Header.Get("Authorization")
			if !strings.HasPrefix(auth, "Bearer ") {
				http.Error(w, "unauthorized", http.StatusUnauthorized)
				return
			}
			tok := strings.TrimPrefix(auth, "Bearer ")

			// Kiểm tra token có trong blacklist không
			if blacklistChecker != nil {
				isBlacklisted, err := blacklistChecker.IsBlacklisted(tok)
				if err != nil {
					http.Error(w, "internal server error", http.StatusInternalServerError)
					return
				}
				if isBlacklisted {
					http.Error(w, "token has been revoked", http.StatusUnauthorized)
					return
				}
			}

			parsed, err := jwt.ParseWithClaims(tok, &Claims{}, func(token *jwt.Token) (interface{}, error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, errors.New("unexpected signing method")
				}
				return []byte(secret), nil
			})
			if err != nil || !parsed.Valid {
				http.Error(w, "invalid token", http.StatusUnauthorized)
				return
			}
			claims := parsed.Claims.(*Claims)
			ctx := context.WithValue(r.Context(), claimsKey, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func RequireRole(roles ...string) func(http.Handler) http.Handler {
	set := map[string]struct{}{}
	for _, r := range roles {
		set[r] = struct{}{}
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			claims := GetClaims(r.Context())
			if claims == nil {
				http.Error(w, "forbidden", http.StatusForbidden)
				return
			}
			if _, ok := set[claims.Role]; !ok {
				http.Error(w, "forbidden", http.StatusForbidden)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
