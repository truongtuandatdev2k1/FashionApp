package repositories

import (
	"context"
	"myfashion/internal/modules/catalog/entities"
	"sort"
	"time"

	"gorm.io/gorm"
)

type ProductSimilarityRepository struct {
	db *gorm.DB
}

func NewProductSimilarityRepository(db *gorm.DB) *ProductSimilarityRepository {
	return &ProductSimilarityRepository{db: db}
}

type SimilarityRequest struct {
	ProductID uint
	Limit     int
	Source    string // e.g., "bought_together"
}

func (r *ProductSimilarityRepository) GetSimilar(ctx context.Context, req SimilarityRequest) ([]*entities.Product, error) {
	limit := req.Limit
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	if req.Source == "" {
		req.Source = "bought_together"
	}

	// Get similar product IDs from cache table
	var rows []ProductSimilarityModel
	if err := r.db.WithContext(ctx).
		Where("product_id = ? AND source = ?", req.ProductID, req.Source).
		Order("score DESC").
		Limit(limit).
		Find(&rows).Error; err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return []*entities.Product{}, nil
	}

	ids := make([]uint, len(rows))
	for i, row := range rows {
		ids[i] = row.SimilarProductID
	}

	// Load full product entities with preloads
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

// RebuildSimilaritiesFromOrders rebuilds the similarity cache from order_items.
// It deletes old entries for the given source and recomputes top K per product.
func (r *ProductSimilarityRepository) RebuildSimilaritiesFromOrders(ctx context.Context, source string, topK int) error {
	// Delete old cache for this source
	if err := r.db.WithContext(ctx).Where("source = ?", source).Delete(&ProductSimilarityModel{}).Error; err != nil {
		return err
	}

	// Compute co-occurrence from orders
	type coRow struct {
		ProductID        uint
		SimilarProductID uint
		Cnt              int
	}
	var rows []coRow
	if err := r.db.WithContext(ctx).
		Table("order_items oi").
		Select("oi.product_id as product_id, oi2.product_id as similar_product_id, COUNT(DISTINCT oi.order_id) as cnt").
		Joins("JOIN orders o ON o.id = oi.order_id").
		Joins("JOIN order_items oi2 ON oi2.order_id = oi.order_id").
		Where("oi.product_id != oi2.product_id").
		Where("oi.product_id < oi2.product_id"). // avoid duplicate pairs (A,B) vs (B,A)
		Where("UPPER(o.status) != ?", "CANCELLED").
		Group("oi.product_id, oi2.product_id").
		Order("cnt DESC").
		Find(&rows).Error; err != nil {
		return err
	}

	// For each product, keep top K similar items
	topMap := make(map[uint][]coRow)
	for _, row := range rows {
		topMap[row.ProductID] = append(topMap[row.ProductID], row)
		topMap[row.SimilarProductID] = append(topMap[row.SimilarProductID], coRow{
			ProductID:        row.SimilarProductID,
			SimilarProductID: row.ProductID,
			Cnt:              row.Cnt,
		})
	}

	// Prepare batch insert
	var batch []ProductSimilarityModel
	for pid, items := range topMap {
		// Sort by count desc, tie by SimilarProductID asc for stability
		sort.Slice(items, func(i, j int) bool {
			if items[i].Cnt == items[j].Cnt {
				return items[i].SimilarProductID < items[j].SimilarProductID
			}
			return items[i].Cnt > items[j].Cnt
		})
		if len(items) > topK {
			items = items[:topK]
		}
		for _, item := range items {
			batch = append(batch, ProductSimilarityModel{
				ProductID:        pid,
				SimilarProductID: item.SimilarProductID,
				Score:            float64(item.Cnt),
				Source:           source,
				UpdatedAt:        time.Now(),
			})
		}
	}

	// Batch insert
	if len(batch) > 0 {
		const batchSize = 500
		for i := 0; i < len(batch); i += batchSize {
			end := i + batchSize
			if end > len(batch) {
				end = len(batch)
			}
			if err := r.db.WithContext(ctx).Create(batch[i:end]).Error; err != nil {
				return err
			}
		}
	}
	return nil
}
