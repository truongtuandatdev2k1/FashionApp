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

	// 4) Cold-start fallback: if still insufficient, fetch generic active in-stock products
	if len(out) < limit {
		fallbackNeeded := limit - len(out)
		fallback, err := r.fetchFallback(ctx, req.UserID, req.ProductID, fallbackNeeded, seen)
		if err == nil {
			out = append(out, fallback...)
		}
		// If fallback fails, we still return whatever we have (may be empty)
	}

	return out, nil
}

// fetchFallback returns generic active in-stock products when personalized data is insufficient.
// It respects exclusions (current product, purchased products) and uses deterministic ordering.
func (r *MixedRecommendationRepository) fetchFallback(ctx context.Context, userID, productID uint, needed int, seen map[uint]struct{}) ([]*entities.Product, error) {
	// Prepare exclusions
	excluded := map[uint]struct{}{productID: {}}
	for id := range seen {
		excluded[id] = struct{}{}
	}
	if userID != 0 {
		var purchasedIDs []uint
		_ = r.db.WithContext(ctx).Table("orders").
			Select("DISTINCT order_items.product_id").
			Joins("JOIN order_items ON order_items.order_id = orders.id").
			Where("orders.customer_id = ?", userID).
			Where("UPPER(orders.status) != ?", "CANCELLED").
			Limit(5000).
			Pluck("order_items.product_id", &purchasedIDs).Error
		for _, id := range purchasedIDs {
			excluded[id] = struct{}{}
		}
	}
	excludedIDs := make([]uint, 0, len(excluded))
	for id := range excluded {
		excludedIDs = append(excludedIDs, id)
	}

	// Query generic active in-stock products, ordered deterministically (e.g., by updated_at DESC)
	var models []ProductModel
	q := r.db.WithContext(ctx).Model(&ProductModel{}).
		Joins("LEFT JOIN product_stats ON product_stats.product_id = products.id").
		Where("UPPER(products.status) = ?", "ACTIVE").
		Where("COALESCE(product_stats.total_stock, 0) > 0")
	if len(excludedIDs) > 0 {
		q = q.Where("products.id NOT IN ?", excludedIDs)
	}
	if err := q.
		Preload("Brand").
		Preload("Categories").
		Preload("Styles").
		Preload("Variants").
		Preload("Variants.ProductColor").
		Order("products.updated_at DESC").
		Limit(needed).
		Find(&models).Error; err != nil {
		return nil, err
	}

	return modelsToEntities(models), nil
}
