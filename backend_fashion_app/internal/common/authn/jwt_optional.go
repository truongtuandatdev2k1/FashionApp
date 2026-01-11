package authn

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

// AuthOptionalWithBlacklistAndUserStatus parses JWT if present.
// - If Authorization header is missing: request continues as anonymous.
// - If token is present but invalid/blacklisted/disabled: request continues as anonymous.
// It never returns 401/403.
func AuthOptionalWithBlacklistAndUserStatus(secret string, blacklistChecker BlacklistChecker, userStatusChecker UserStatusChecker) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			auth := r.Header.Get("Authorization")
			if !strings.HasPrefix(auth, "Bearer ") {
				next.ServeHTTP(w, r)
				return
			}
			tok := strings.TrimPrefix(auth, "Bearer ")

			if blacklistChecker != nil {
				isBlacklisted, err := blacklistChecker.IsBlacklisted(tok)
				if err != nil || isBlacklisted {
					next.ServeHTTP(w, r)
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
				next.ServeHTTP(w, r)
				return
			}

			claims, ok := parsed.Claims.(*Claims)
			if !ok || claims == nil {
				next.ServeHTTP(w, r)
				return
			}

			if userStatusChecker != nil {
				active, err := userStatusChecker.IsActive(r.Context(), claims.UID)
				if err != nil || !active {
					next.ServeHTTP(w, r)
					return
				}
			}

			ctx := context.WithValue(r.Context(), claimsKey, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

