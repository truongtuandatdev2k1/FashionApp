package services

import (
	"context"
	"log"
	"time"
)

type ExpiringPromotionScheduler struct {
	promoRepo        PromotionRepository
	notificationSvc  NotificationService
	expiringWithin   time.Duration
	interval         time.Duration
}

func NewExpiringPromotionScheduler(promoRepo PromotionRepository, notificationSvc NotificationService, expiringWithin, interval time.Duration) *ExpiringPromotionScheduler {
	return &ExpiringPromotionScheduler{
		promoRepo:       promoRepo,
		notificationSvc: notificationSvc,
		expiringWithin:  expiringWithin,
		interval:        interval,
	}
}

func (s *ExpiringPromotionScheduler) RunOnce(ctx context.Context) {
	if s.notificationSvc == nil {
		return
	}
	before := time.Now().Add(s.expiringWithin)
	promos, err := s.promoRepo.FindExpiringActive(ctx, before)
	if err != nil {
		log.Printf("expiring promo scheduler error: %v", err)
		return
	}
	for _, p := range promos {
		_ = s.notificationSvc.NotifyPromotionExpiring(ctx, p.Code, p.EndDate)
	}
}

func (s *ExpiringPromotionScheduler) Start(ctx context.Context) {
	ticker := time.NewTicker(s.interval)
	defer ticker.Stop()

	log.Printf("Starting expiring promotion scheduler with interval: %v", s.interval)

	for {
		select {
		case <-ctx.Done():
			log.Println("Expiring promotion scheduler stopped")
			return
		case <-ticker.C:
			s.RunOnce(ctx)
		}
	}
}

