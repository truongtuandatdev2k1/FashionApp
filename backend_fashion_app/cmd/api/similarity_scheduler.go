package main

import (
	"context"
	"log"
	"time"

	catalogRepos "myfashion/internal/modules/catalog/repositories"
)

func startSimilarityScheduler(ctx context.Context, repo *catalogRepos.ProductSimilarityRepository, interval time.Duration, topK int) {
	if topK <= 0 {
		topK = 50
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	log.Printf("Starting similarity recompute scheduler with interval: %v", interval)

	run := func() {
		if err := repo.RebuildSimilaritiesFromOrders(ctx, "bought_together", topK); err != nil {
			log.Printf("Error recomputing similarities: %v", err)
		} else {
			log.Printf("Similarity recompute completed (source=bought_together, topK=%d)", topK)
		}
	}

	// Run once on start
	run()

	for {
		select {
		case <-ctx.Done():
			log.Println("Similarity recompute scheduler stopped")
			return
		case <-ticker.C:
			run()
		}
	}
}

