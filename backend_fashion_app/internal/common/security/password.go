package security

import "golang.org/x/crypto/bcrypt"

type PasswordHasher interface {
	Hash(raw string) (string, error)
	Verify(hash, raw string) bool
}

type BcryptHasher struct{}

func (BcryptHasher) Hash(raw string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(raw), bcrypt.DefaultCost)
	return string(b), err
}
func (BcryptHasher) Verify(hash, raw string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(raw)) == nil
}
