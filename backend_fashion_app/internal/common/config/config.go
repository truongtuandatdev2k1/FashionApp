package config

import (
	"os"

	_ "github.com/joho/godotenv/autoload" // Tự động load .env nếu tồn tại
)

type Config struct {
	Port              string
	DB_DSN            string
	JWT_Secret        string
	JWT_RefreshSecret string
	JWT_AccessTTLMin  int
	JWT_RefreshTTLD   int
	GoogleClientID    string
}

func Load() Config {
	return Config{
		Port:              getEnv("PORT", "4003"),
		DB_DSN:            getEnv("DB_DSN", ""),
		JWT_Secret:        getEnv("JWT_SECRET", ""),
		JWT_RefreshSecret: getEnv("JWT_REFRESH_SECRET", ""),
		JWT_AccessTTLMin:  getEnvInt("JWT_ACCESS_TTL_MIN", 60),
		JWT_RefreshTTLD:   getEnvInt("JWT_REFRESH_TTL_DAYS", 30),
		GoogleClientID:    getEnv("GOOGLE_CLIENT_ID", ""),
	}
}

func getEnv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func getEnvInt(k string, def int) int {
	if v := os.Getenv(k); v != "" {
		// simple parse to int, ignore error => use def on failure
		n := 0
		for i := 0; i < len(v); i++ {
			if v[i] < '0' || v[i] > '9' {
				return def
			}
			n = n*10 + int(v[i]-'0')
		}
		return n
	}
	return def
}
