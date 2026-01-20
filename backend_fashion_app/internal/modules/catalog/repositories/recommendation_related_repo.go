package repositories

import (
	"context"
	"math"
	"sort"

	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type RelatedRecommendationRepository struct {
	db *gorm.DB
}

func NewRelatedRecommendationRepository(db *gorm.DB) *RelatedRecommendationRepository {
	return &RelatedRecommendationRepository{db: db}
}

type RelatedRequest struct {
	UserID    uint
	ProductID uint
	Limit     int
}

func (r *RelatedRecommendationRepository) GetRelated(ctx context.Context, req RelatedRequest) ([]*entities.Product, error) {
	limit := req.Limit
	if limit <= 0 || limit > 50 {
		limit = 10
	}

	// Load product taxonomy
	var prod ProductModel
	if err := r.db.WithContext(ctx).
		Model(&ProductModel{}).
		Where("id = ?", req.ProductID).
		Where("UPPER(status) = ?", "ACTIVE").
		Preload("Categories").
		Preload("Styles").
		First(&prod).Error; err != nil {
		return nil, err
	}

	// loại trừ sản phẩm hết hàng (theo product_stats)
	var stats ProductStatsModel
	if err := r.db.WithContext(ctx).Where("product_id = ?", req.ProductID).First(&stats).Error; err == nil {
		if stats.TotalStock <= 0 {
			return []*entities.Product{}, nil
		}
	}

	categoryIDs := make([]uint, 0, len(prod.Categories))
	for _, c := range prod.Categories {
		categoryIDs = append(categoryIDs, c.ID)
	}
	styleIDs := make([]uint, 0, len(prod.Styles))
	for _, s := range prod.Styles {
		styleIDs = append(styleIDs, s.ID)
	}

	excluded := map[uint]struct{}{}
	// exclude current product
	excluded[req.ProductID] = struct{}{}
	// exclude purchased products
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

	// Candidate query
	excludedIDs := make([]uint, 0, len(excluded))
	for id := range excluded {
		excludedIDs = append(excludedIDs, id)
	}

	q := r.db.WithContext(ctx).Model(&ProductModel{}).
		Joins("LEFT JOIN product_stats ON product_stats.product_id = products.id").
		Where("UPPER(products.status) = ?", "ACTIVE").
		Where("COALESCE(product_stats.total_stock, 0) > 0")
	if len(excludedIDs) > 0 {
		q = q.Where("products.id NOT IN ?", excludedIDs)
	}

	if prod.BrandID != nil {
		q = q.Where("products.brand_id = ?", *prod.BrandID)
	}
	if len(categoryIDs) > 0 {
		q = q.Joins("LEFT JOIN product_categories pc ON pc.product_model_id = products.id").
			Where("pc.category_model_id IN ?", categoryIDs)
	}
	if len(styleIDs) > 0 {
		q = q.Joins("LEFT JOIN product_styles ps ON ps.product_model_id = products.id").
			Where("ps.style_model_id IN ?", styleIDs)
	}

	// pull more for rerank
	pull := int(math.Max(float64(limit*15), 150))
	var models []ProductModel
	if err := q.
		Preload("Brand").
		Preload("Categories").
		Preload("Styles").
		Preload("Variants").
		Preload("Variants.ProductColor").
		Order("products.updated_at DESC").
		Limit(pull).
		Find(&models).Error; err != nil {
		return nil, err
	}

	// Simple rerank: shared category/style + same brand bonus
	items := modelsToEntities(models)
	scored := make([]scoredProduct, 0, len(items))
	catSet := map[uint]struct{}{}
	for _, id := range categoryIDs {
		catSet[id] = struct{}{}
	}
	styleSet := map[uint]struct{}{}
	for _, id := range styleIDs {
		styleSet[id] = struct{}{}
	}

	for _, p := range items {
		s := 0.0
		for _, c := range p.Categories {
			if _, ok := catSet[c.ID]; ok {
				s += 1.0
			}
		}
		for _, st := range p.Styles {
			if _, ok := styleSet[st.ID]; ok {
				s += 1.0
			}
		}
		if prod.BrandID != nil && p.BrandID != nil && *p.BrandID == *prod.BrandID {
			s += 1.5
		}
		scored = append(scored, scoredProduct{product: p, score: s})
	}

	sort.Slice(scored, func(i, j int) bool {
		if scored[i].score == scored[j].score {
			return scored[i].product.ID < scored[j].product.ID
		}
		return scored[i].score > scored[j].score
	})

	out := make([]*entities.Product, 0, limit)
	seen := map[uint]struct{}{}
	for i := 0; i < len(scored) && len(out) < limit; i++ {
		id := scored[i].product.ID
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		out = append(out, scored[i].product)
	}

	return out, nil
}

