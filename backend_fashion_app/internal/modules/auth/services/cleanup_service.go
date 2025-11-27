package services

import (
	"context"
	"log"
	"myfashion/internal/modules/auth/repositories"
	"time"
)

type CleanupService struct {
	blacklistRepo *repositories.BlacklistedTokenRepository
}

func NewCleanupService(blacklistRepo *repositories.BlacklistedTokenRepository) *CleanupService {
	return &CleanupService{
		blacklistRepo: blacklistRepo,
	}
}

// CleanupExpiredTokens xóa các token đã hết hạn khỏi blacklist
func (s *CleanupService) CleanupExpiredTokens(ctx context.Context) error {
	return s.blacklistRepo.CleanupExpiredTokens()
}

// StartCleanupScheduler chạy cleanup job định kỳ
func (s *CleanupService) StartCleanupScheduler(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	log.Printf("Starting blacklist cleanup scheduler with interval: %v", interval)

	for {
		select {
		case <-ctx.Done():
			log.Println("Blacklist cleanup scheduler stopped")
			return
		case <-ticker.C:
			if err := s.CleanupExpiredTokens(ctx); err != nil {
				log.Printf("Error cleaning up expired tokens: %v", err)
			} else {
				// Log số lượng token đã cleanup (optional)
				activeCount, _ := s.blacklistRepo.GetActiveTokensCount()
				log.Printf("Blacklist cleanup completed. Active tokens: %d", activeCount)
			}
		}
	}
}

// GetBlacklistStats trả về thống kê blacklist (để monitoring)
func (s *CleanupService) GetBlacklistStats(ctx context.Context) (map[string]int64, error) {
	activeCount, err := s.blacklistRepo.GetActiveTokensCount()
	if err != nil {
		return nil, err
	}

	expiredCount, err := s.blacklistRepo.GetExpiredTokensCount()
	if err != nil {
		return nil, err
	}

	return map[string]int64{
		"active_tokens":  activeCount,
		"expired_tokens": expiredCount,
		"total_tokens":   activeCount + expiredCount,
	}, nil
}
