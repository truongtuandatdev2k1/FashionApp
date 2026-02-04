package repositories

import (
	"context"

	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type BoughtTogetherRecommendationRepository struct {
	db *gorm.DB
}

func NewBoughtTogetherRecommendationRepository(db *gorm.DB) *BoughtTogetherRecommendationRepository {
	return &BoughtTogetherRecommendationRepository{db: db}
}

type BoughtTogetherRequest struct {
	UserID    uint
	ProductID uint
	Limit     int
}

type boughtTogetherRow struct {
	ProductID uint
	Cnt       int
}

func (r *BoughtTogetherRecommendationRepository) GetBoughtTogether(ctx context.Context, req BoughtTogetherRequest) ([]*entities.Product, error) {
	limit := req.Limit
	if limit <= 0 || limit > 50 {
		limit = 10
	}

	// Excluded: current product + purchased products
	excluded := map[uint]struct{}{req.ProductID: {}}
	if req.UserID != 0 {
		var purchasedIDs []uint
		_ = r.db.WithContext(ctx).Table("orders").
			Select("DISTINCT order_items.product_id").
			Joins("JOIN order_items ON order_items.order_id = orders.id").
			Where("orders.customer_id = ?", req.UserID).
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

	// Cache-first: read from product_similarities if available
	simRepo := NewProductSimilarityRepository(r.db)
	cached, err := simRepo.GetSimilar(ctx, SimilarityRequest{ProductID: req.ProductID, Limit: limit, Source: "bought_together"})
	if err != nil {
		return nil, err
	}
	if len(cached) > 0 {
		// Extra safety: exclude purchased/current just in case cache is stale
		out := make([]*entities.Product, 0, limit)
		seen := map[uint]struct{}{}
		for _, p := range cached {
			if p == nil {
				continue
			}
			if _, ok := excluded[p.ID]; ok {
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

	// Fallback: compute directly from order_items, ranked by COUNT(DISTINCT order_id)
	q := r.db.WithContext(ctx).
		Table("order_items oi").
		Select("oi2.product_id as product_id, COUNT(DISTINCT oi2.order_id) as cnt").
		Joins("JOIN orders o ON o.id = oi.order_id").
		Joins("JOIN order_items oi2 ON oi2.order_id = oi.order_id").
		Joins("JOIN products p ON p.id = oi2.product_id").
		Joins("LEFT JOIN product_stats ps ON ps.product_id = p.id").
		Where("oi.product_id = ?", req.ProductID).
		Where("oi2.product_id != ?", req.ProductID).
		Where("UPPER(o.status) != ?", "CANCELLED").
		Where("UPPER(p.status) = ?", "ACTIVE").
		Where("COALESCE(ps.total_stock, 0) > 0")
	if len(excludedIDs) > 0 {
		q = q.Where("oi2.product_id NOT IN ?", excludedIDs)
	}

	var rows []boughtTogetherRow
	if err := q.Group("oi2.product_id").
		Order("cnt DESC").
		Limit(limit * 10).
		Scan(&rows).Error; err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return []*entities.Product{}, nil
	}

	ids := make([]uint, 0, len(rows))
	seen := map[uint]struct{}{}
	for _, row := range rows {
		if row.ProductID == 0 {
			continue
		}
		if _, ok := seen[row.ProductID]; ok {
			continue
		}
		seen[row.ProductID] = struct{}{}
		ids = append(ids, row.ProductID)
		if len(ids) >= limit {
			break
		}
	}
	if len(ids) == 0 {
		return []*entities.Product{}, nil
	}

	var models []ProductModel
	if err := r.db.WithContext(ctx).Model(&ProductModel{}).
		Where("id IN ?", ids).
		Preload("Brand").
		Preload("Categories").
		Preload("Styles").
		Preload("Variants").
		Preload("Variants.ProductColor").
		Find(&models).Error; err != nil {
		return nil, err
	}

	mByID := map[uint]ProductModel{}
	for _, m := range models {
		mByID[m.ID] = m
	}

	out := make([]*entities.Product, 0, len(ids))
	for _, id := range ids {
		if m, ok := mByID[id]; ok {
			out = append(out, modelsToEntities([]ProductModel{m})[0])
		}
	}

	return out, nil
}
