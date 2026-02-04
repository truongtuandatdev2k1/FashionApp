package repositories

import (
	"context"

	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type MixedRecommendationRepository struct {
	db *gorm.DB
}

func NewMixedRecommendationRepository(db *gorm.DB) *MixedRecommendationRepository {
	return &MixedRecommendationRepository{db: db}
}

type MixedRequest struct {
	UserID    uint
	ProductID uint
	Limit     int
}

func (r *MixedRecommendationRepository) GetMixed(ctx context.Context, req MixedRequest) ([]*entities.Product, error) {
	limit := req.Limit
	if limit <= 0 || limit > 50 {
		limit = 10
	}

	// Prioritize similar (content-based) at 70% of limit
	similarLimit := (limit * 7) / 10
	if similarLimit < 1 {
		similarLimit = 1
	}

	// 1) Get similar (content-based) items
	similarRepo := NewRelatedRecommendationRepository(r.db)
	similarItems, err := similarRepo.GetRelated(ctx, RelatedRequest{UserID: req.UserID, ProductID: req.ProductID, Limit: similarLimit})
	if err != nil {
		return nil, err
	}

	// 2) Get bought-together (CF) items
	btRepo := NewBoughtTogetherRecommendationRepository(r.db)
	btFetch := limit
	if btFetch < 10 {
		btFetch = 10
	}
	btItems, err := btRepo.GetBoughtTogether(ctx, BoughtTogetherRequest{UserID: req.UserID, ProductID: req.ProductID, Limit: btFetch})
	if err != nil {
		return nil, err
	}

	// 3) Merge: prioritize similar, then fill with bought-together, dedupe by product_id
	seen := map[uint]struct{}{}
	out := make([]*entities.Product, 0, limit)

	// Add similar first
	for _, p := range similarItems {
		if p == nil {
			continue
		}
		if _, ok := seen[p.ID]; ok {
			continue
		}
		seen[p.ID] = struct{}{}
		out = append(out, p)
	}

	// Fill remaining with bought-together
	for _, p := range btItems {
		if p == nil {
			continue
		}
		if _, ok := seen[p.ID]; ok {
			continue
		}
		seen[p.ID] = struct{}{}
		out = append(out, p)
		if len(out) >= limit {
			break
		}
	}

	return out, nil
}
