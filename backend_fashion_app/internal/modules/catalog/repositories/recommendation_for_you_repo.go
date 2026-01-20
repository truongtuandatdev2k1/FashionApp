package repositories

import (
	"context"
	"math"
	"sort"
	"strings"

	"myfashion/internal/modules/catalog/entities"

	"gorm.io/gorm"
)

type ForYouRecommendationRepository struct {
	db *gorm.DB
}

func NewForYouRecommendationRepository(db *gorm.DB) *ForYouRecommendationRepository {
	return &ForYouRecommendationRepository{db: db}
}

type ForYouPreferences struct {
	BrandWeights    map[uint]float64
	CategoryWeights map[uint]float64
	StyleWeights    map[uint]float64
	ColorWeights    map[string]float64
	SizeWeights     map[string]float64
	PriceMean       float64
	PriceMin        float64
	PriceMax        float64
}

type ForYouRequest struct {
	UserID uint
	Limit  int
}

type scoredProduct struct {
	product *entities.Product
	score   float64
}

type bestsellerRow struct {
	ProductID uint
}

func (r *ForYouRecommendationRepository) GetForYou(ctx context.Context, req ForYouRequest) ([]*entities.Product, error) {
	limit := req.Limit
	if limit <= 0 || limit > 50 {
		limit = 10
	}

	prefs, excludedIDs, err := r.buildPrefsAndExcluded(ctx, req.UserID)
	if err != nil {
		return nil, err
	}

	candidates, err := r.loadCandidates(ctx, req.UserID, prefs, excludedIDs, limit)
	if err != nil {
		return nil, err
	}

	if len(candidates) == 0 {
		return []*entities.Product{}, nil
	}

	scored := make([]scoredProduct, 0, len(candidates))
	for _, p := range candidates {
		s := scoreProduct(p, prefs)
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

type cartSignalRow struct {
	ProductID uint
	BrandID   *uint
	ColorHex  string
	SizeCode  string
	Qty       int
	Price     float64
}

type orderSignalRow struct {
	ProductID uint
	BrandID   *uint
	Color     string
	Size      string
	Qty       int
	Price     float64
}

type viewSignalRow struct {
	ProductID uint
	BrandID   *uint
	Price     float64
}

func (r *ForYouRecommendationRepository) buildPrefsAndExcluded(ctx context.Context, userID uint) (*ForYouPreferences, map[uint]struct{}, error) {
	prefs := &ForYouPreferences{
		BrandWeights:    map[uint]float64{},
		CategoryWeights: map[uint]float64{},
		StyleWeights:    map[uint]float64{},
		ColorWeights:    map[string]float64{},
		SizeWeights:     map[string]float64{},
		PriceMin:        math.MaxFloat64,
	}

	excluded := map[uint]struct{}{}

	var prices []float64
	addPrice := func(v float64, count int) {
		if v <= 0 {
			return
		}
		for i := 0; i < count; i++ {
			prices = append(prices, v)
		}
		if v < prefs.PriceMin {
			prefs.PriceMin = v
		}
		if v > prefs.PriceMax {
			prefs.PriceMax = v
		}
	}

	addProductTaxonomy := func(productID uint, weight float64) {
		if productID == 0 {
			return
		}
		var catIDs []uint
		_ = r.db.WithContext(ctx).Table("product_categories").Where("product_model_id = ?", productID).Pluck("category_model_id", &catIDs).Error
		for _, id := range catIDs {
			prefs.CategoryWeights[id] += weight
		}

		var styleIDs []uint
		_ = r.db.WithContext(ctx).Table("product_styles").Where("product_model_id = ?", productID).Pluck("style_model_id", &styleIDs).Error
		for _, id := range styleIDs {
			prefs.StyleWeights[id] += weight
		}
	}

	// --- Cart signals (highest weight) ---
	var cartRows []cartSignalRow
	if err := r.db.WithContext(ctx).
		Table("carts").
		Select("products.id as product_id, products.brand_id as brand_id, product_colors.color_hex as color_hex, product_variants.size_code as size_code, cart_items.quantity as qty, cart_items.price_snapshot as price").
		Joins("JOIN cart_items ON cart_items.cart_id = carts.id").
		Joins("JOIN product_variants ON product_variants.id = cart_items.product_variant_id").
		Joins("JOIN product_colors ON product_colors.id = product_variants.product_color_id").
		Joins("JOIN products ON products.id = product_variants.product_id").
		Where("carts.user_id = ?", userID).
		Where("UPPER(products.status) = ?", "ACTIVE").
		Scan(&cartRows).Error; err != nil {
		return nil, nil, err
	}

	for _, row := range cartRows {
		w := float64(max(row.Qty, 1))

		if row.BrandID != nil {
			prefs.BrandWeights[*row.BrandID] += 5.0 * w
		}
		if row.ColorHex != "" {
			prefs.ColorWeights[strings.ToUpper(row.ColorHex)] += 4.0 * w
		}
		if row.SizeCode != "" {
			prefs.SizeWeights[strings.ToUpper(row.SizeCode)] += 3.0 * w
		}
		addPrice(row.Price, max(row.Qty, 1))
		addProductTaxonomy(row.ProductID, 6.0*w)
	}

	// --- Order signals (medium weight) ---
	var orderRows []orderSignalRow
	if err := r.db.WithContext(ctx).
		Table("orders").
		Select("order_items.product_id as product_id, products.brand_id as brand_id, order_items.color as color, order_items.size as size, order_items.quantity as qty, order_items.price as price").
		Joins("JOIN order_items ON order_items.order_id = orders.id").
		Joins("JOIN products ON products.id = order_items.product_id").
		Where("orders.customer_id = ?", userID).
		Where("UPPER(orders.status) != ?", "CANCELLED").
		Where("UPPER(products.status) = ?", "ACTIVE").
		Order("orders.created_at DESC").
		Limit(300).
		Scan(&orderRows).Error; err != nil {
		return nil, nil, err
	}

	for _, row := range orderRows {
		w := float64(max(row.Qty, 1))
		if row.BrandID != nil {
			prefs.BrandWeights[*row.BrandID] += 3.0 * w
		}
		c := strings.ToUpper(strings.TrimSpace(row.Color))
		if strings.HasPrefix(c, "#") && len(c) == 7 {
			prefs.ColorWeights[c] += 1.0 * w
		}
		s := strings.ToUpper(strings.TrimSpace(row.Size))
		if s != "" {
			prefs.SizeWeights[s] += 1.0 * w
		}
		addPrice(row.Price, max(row.Qty, 1))
		addProductTaxonomy(row.ProductID, 2.0*w)
	}

	// --- View signals (lowest weight) ---
	var viewRows []viewSignalRow
	if err := r.db.WithContext(ctx).
		Table("product_views").
		Select("product_views.product_id as product_id, products.brand_id as brand_id, products.price_after as price").
		Joins("JOIN products ON products.id = product_views.product_id").
		Where("product_views.user_id = ?", userID).
		Where("UPPER(products.status) = ?", "ACTIVE").
		Order("product_views.viewed_at DESC").
		Limit(100).
		Scan(&viewRows).Error; err != nil {
		return nil, nil, err
	}

	for _, row := range viewRows {
		if row.BrandID != nil {
			prefs.BrandWeights[*row.BrandID] += 0.5
		}
		addPrice(row.Price, 1)
		addProductTaxonomy(row.ProductID, 0.8)
	}

	// Wishlist signals (medium-high weight)
	var wishlistRows []struct {
		ProductID uint
		BrandID   *uint
	}
	if err := r.db.WithContext(ctx).
		Table("wishlist_items").
		Select("wishlist_items.product_id as product_id, products.brand_id as brand_id").
		Joins("JOIN products ON products.id = wishlist_items.product_id").
		Where("wishlist_items.user_id = ?", userID).
		Where("UPPER(products.status) = ?", "ACTIVE").
		Order("wishlist_items.created_at DESC").
		Limit(500).
		Scan(&wishlistRows).Error; err != nil {
		return nil, nil, err
	}
	for _, row := range wishlistRows {
		addProductTaxonomy(row.ProductID, 2.2)
		if row.BrandID != nil {
			prefs.BrandWeights[*row.BrandID] += 2.0
		}
		// (Không có màu/size trong wishlist_items hiện tại)
	}

	// Exclude purchased products (strong exclude)
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

	// Compute price mean
	if len(prices) > 0 {
		var sum float64
		for _, v := range prices {
			sum += v
		}
		prefs.PriceMean = sum / float64(len(prices))
	}
	if prefs.PriceMin == math.MaxFloat64 {
		prefs.PriceMin = 0
	}

	return prefs, excluded, nil
}

func (r *ForYouRecommendationRepository) loadCandidates(ctx context.Context, userID uint, prefs *ForYouPreferences, excluded map[uint]struct{}, want int) ([]*entities.Product, error) {
	target := want
	if target <= 0 {
		target = 10
	}

	out := make([]*entities.Product, 0, target)
	seen := map[uint]struct{}{}

	appendProducts := func(items []*entities.Product) {
		for _, p := range items {
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
			if len(out) >= target {
				return
			}
		}
	}

	// Stage 1: Prefer same category/style first (seeded from cart/views/orders)
	categoryIDs := topKeys(prefs.CategoryWeights, 5)
	styleIDs := topKeys(prefs.StyleWeights, 5)
	if len(categoryIDs) > 0 || len(styleIDs) > 0 {
		items, err := r.queryByTaxonomy(ctx, categoryIDs, styleIDs, excluded, 250)
		if err != nil {
			return nil, err
		}
		appendProducts(items)
		if len(out) >= target {
			return out, nil
		}
	}

	// Stage 2: from preferred brands + price window
	brandIDs := topKeys(prefs.BrandWeights, 5)
	if len(brandIDs) > 0 || prefs.PriceMean > 0 {
		items, err := r.queryProducts(ctx, brandIDs, prefs.PriceMean, excluded, 200, "")
		if err != nil {
			return nil, err
		}
		appendProducts(items)
		if len(out) >= target {
			return out, nil
		}
	}

	// Stage 3: from last viewed product taxonomy if still low
	var lastViewed struct {
		ProductID uint
	}
	_ = r.db.WithContext(ctx).
		Table("product_views").
		Select("product_views.product_id as product_id").
		Joins("JOIN products ON products.id = product_views.product_id").
		Where("product_views.user_id = ?", userID).
		Where("UPPER(products.status) = ?", "ACTIVE").
		Order("product_views.viewed_at DESC").
		Limit(1).
		Scan(&lastViewed).Error

	if len(out) < target && lastViewed.ProductID != 0 {
		var catIDs []uint
		_ = r.db.WithContext(ctx).Table("product_categories").Where("product_model_id = ?", lastViewed.ProductID).Pluck("category_model_id", &catIDs).Error
		var stIDs []uint
		_ = r.db.WithContext(ctx).Table("product_styles").Where("product_model_id = ?", lastViewed.ProductID).Pluck("style_model_id", &stIDs).Error
		items, err := r.queryByTaxonomy(ctx, catIDs, stIDs, excluded, 200)
		if err != nil {
			return nil, err
		}
		appendProducts(items)
		if len(out) >= target {
			return out, nil
		}
	}

	// Stage 4: fallback bestseller > hottrend > newest
	if len(out) < target {
		items, err := r.queryBestseller(ctx, excluded, 200)
		if err != nil {
			return nil, err
		}
		appendProducts(items)
		if len(out) >= target {
			return out, nil
		}
	}

	if len(out) < target {
		items, err := r.queryHotTrend(ctx, excluded, 200)
		if err != nil {
			return nil, err
		}
		appendProducts(items)
		if len(out) >= target {
			return out, nil
		}
	}

	if len(out) < target {
		items, err := r.queryNewest(ctx, excluded, 200)
		if err != nil {
			return nil, err
		}
		appendProducts(items)
	}

	return out, nil
}

func (r *ForYouRecommendationRepository) queryByTaxonomy(ctx context.Context, categoryIDs []uint, styleIDs []uint, excluded map[uint]struct{}, limit int) ([]*entities.Product, error) {
	if limit <= 0 {
		limit = 200
	}

	excludedIDs := make([]uint, 0, len(excluded))
	for id := range excluded {
		excludedIDs = append(excludedIDs, id)
	}

	q := r.db.WithContext(ctx).Model(&ProductModel{}).
		Joins("LEFT JOIN product_stats ON product_stats.product_id = products.id").
		Where("UPPER(status) = ?", "ACTIVE").
		Where("COALESCE(product_stats.total_stock, 0) > 0")
	if len(excludedIDs) > 0 {
		q = q.Where("products.id NOT IN ?", excludedIDs)
	}

	if len(categoryIDs) > 0 {
		q = q.Joins("JOIN product_categories pc ON pc.product_model_id = products.id").Where("pc.category_model_id IN ?", categoryIDs)
	}
	if len(styleIDs) > 0 {
		q = q.Joins("JOIN product_styles ps ON ps.product_model_id = products.id").Where("ps.style_model_id IN ?", styleIDs)
	}

	var models []ProductModel
	if err := q.Preload("Brand").Preload("Categories").Preload("Styles").Preload("Variants").Preload("Variants.ProductColor").Order("products.created_at DESC").Limit(limit).Find(&models).Error; err != nil {
		return nil, err
	}
	return modelsToEntities(models), nil
}

func (r *ForYouRecommendationRepository) queryProducts(ctx context.Context, brandIDs []uint, priceMean float64, excluded map[uint]struct{}, limit int, orderBy string) ([]*entities.Product, error) {
	q := r.db.WithContext(ctx).Model(&ProductModel{}).
		Joins("LEFT JOIN product_stats ON product_stats.product_id = products.id").
		Where("UPPER(status) = ?", "ACTIVE").
		Where("COALESCE(product_stats.total_stock, 0) > 0")
	if len(excluded) > 0 {
		excludedIDs := make([]uint, 0, len(excluded))
		for id := range excluded {
			excludedIDs = append(excludedIDs, id)
		}
		q = q.Where("id NOT IN ?", excludedIDs)
	}
	if len(brandIDs) > 0 {
		q = q.Where("brand_id IN ?", brandIDs)
	}
	if priceMean > 0 {
		pad := priceMean * 0.3
		minP := math.Max(0, priceMean-pad)
		maxP := priceMean + pad
		q = q.Where("price_after BETWEEN ? AND ?", minP, maxP)
	}
	if orderBy != "" {
		q = q.Order(orderBy)
	}

	var models []ProductModel
	if err := q.Preload("Brand").Preload("Categories").Preload("Styles").Preload("Variants").Preload("Variants.ProductColor").Limit(limit).Find(&models).Error; err != nil {
		return nil, err
	}
	return modelsToEntities(models), nil
}

func (r *ForYouRecommendationRepository) queryHotTrend(ctx context.Context, excluded map[uint]struct{}, limit int) ([]*entities.Product, error) {
	q := r.db.WithContext(ctx).Model(&ProductModel{}).
		Joins("LEFT JOIN product_stats ON product_stats.product_id = products.id").
		Where("UPPER(status) = ?", "ACTIVE").
		Where("COALESCE(product_stats.total_stock, 0) > 0").
		Where("is_hot_trend = ?", true)
	if len(excluded) > 0 {
		excludedIDs := make([]uint, 0, len(excluded))
		for id := range excluded {
			excludedIDs = append(excludedIDs, id)
		}
		q = q.Where("id NOT IN ?", excludedIDs)
	}
	var models []ProductModel
	if err := q.Preload("Brand").Preload("Categories").Preload("Styles").Preload("Variants").Preload("Variants.ProductColor").Order("updated_at DESC").Limit(limit).Find(&models).Error; err != nil {
		return nil, err
	}
	return modelsToEntities(models), nil
}

func (r *ForYouRecommendationRepository) queryNewest(ctx context.Context, excluded map[uint]struct{}, limit int) ([]*entities.Product, error) {
	q := r.db.WithContext(ctx).Model(&ProductModel{}).
		Joins("LEFT JOIN product_stats ON product_stats.product_id = products.id").
		Where("UPPER(status) = ?", "ACTIVE").
		Where("COALESCE(product_stats.total_stock, 0) > 0")
	if len(excluded) > 0 {
		excludedIDs := make([]uint, 0, len(excluded))
		for id := range excluded {
			excludedIDs = append(excludedIDs, id)
		}
		q = q.Where("id NOT IN ?", excludedIDs)
	}
	var models []ProductModel
	if err := q.Preload("Brand").Preload("Categories").Preload("Styles").Preload("Variants").Preload("Variants.ProductColor").Order("created_at DESC").Limit(limit).Find(&models).Error; err != nil {
		return nil, err
	}
	return modelsToEntities(models), nil
}

func (r *ForYouRecommendationRepository) queryBestseller(ctx context.Context, excluded map[uint]struct{}, limit int) ([]*entities.Product, error) {
	q := r.db.WithContext(ctx).
		Table("order_items").
		Select("order_items.product_id as product_id").
		Joins("JOIN orders ON orders.id = order_items.order_id").
		Joins("JOIN products ON products.id = order_items.product_id").
		Where("UPPER(orders.status) != ?", "CANCELLED").
		Where("UPPER(products.status) = ?", "ACTIVE")
	if len(excluded) > 0 {
		excludedIDs := make([]uint, 0, len(excluded))
		for id := range excluded {
			excludedIDs = append(excludedIDs, id)
		}
		q = q.Where("order_items.product_id NOT IN ?", excludedIDs)
	}
	q = q.Group("order_items.product_id").Order("SUM(order_items.quantity) DESC").Limit(limit)

	var rows []bestsellerRow
	if err := q.Scan(&rows).Error; err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return []*entities.Product{}, nil
	}

	ids := make([]uint, 0, len(rows))
	for _, r := range rows {
		ids = append(ids, r.ProductID)
	}

	var models []ProductModel
	if err := r.db.WithContext(ctx).Model(&ProductModel{}).
		Where("id IN ?", ids).
		Preload("Brand").Preload("Categories").Preload("Styles").Preload("Variants").Preload("Variants.ProductColor").
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

func modelsToEntities(models []ProductModel) []*entities.Product {
	products := make([]*entities.Product, len(models))
	for i, m := range models {
		var categories []entities.Category
		for _, catModel := range m.Categories {
			categories = append(categories, *catModel.ToEntity())
		}
		var styles []entities.Style
		for _, styleModel := range m.Styles {
			styles = append(styles, *styleModel.ToEntity())
		}
		products[i] = m.ToEntity(categories, styles)
	}
	return products
}

func scoreProduct(p *entities.Product, prefs *ForYouPreferences) float64 {
	score := 0.0

	for _, c := range p.Categories {
		score += prefs.CategoryWeights[c.ID] * 0.25
	}
	for _, s := range p.Styles {
		score += prefs.StyleWeights[s.ID] * 0.25
	}

	if p.BrandID != nil {
		score += prefs.BrandWeights[*p.BrandID] * 0.3
	}

	// Score by preferred color/size (collected from cart/orders)
	// Note: Product entity already contains variants, each has ProductColor + SizeCode.
	bestColor := 0.0
	bestSize := 0.0
	for _, v := range p.Variants {
		hex := strings.ToUpper(strings.TrimSpace(v.ProductColor.ColorHex))
		if hex != "" {
			if w := prefs.ColorWeights[hex]; w > bestColor {
				bestColor = w
			}
		}
		sz := strings.ToUpper(strings.TrimSpace(v.SizeCode))
		if sz != "" {
			if w := prefs.SizeWeights[sz]; w > bestSize {
				bestSize = w
			}
		}
	}
	// Normalize lightly with log to avoid overpowering category/brand
	if bestColor > 0 {
		score += math.Log1p(bestColor) * 0.08
	}
	if bestSize > 0 {
		score += math.Log1p(bestSize) * 0.06
	}

	if prefs.PriceMean > 0 && p.PriceAfter > 0 {
		maxDist := math.Max(math.Abs(prefs.PriceMax-prefs.PriceMean), math.Abs(prefs.PriceMean-prefs.PriceMin))
		if maxDist > 0 {
			d := math.Abs(p.PriceAfter - prefs.PriceMean)
			priceScore := 1.0 - (d / maxDist)
			score += clamp01(priceScore) * 0.2
		}
	}

	return score
}

func topKeys(m map[uint]float64, n int) []uint {
	type kv struct {
		k uint
		v float64
	}
	arr := make([]kv, 0, len(m))
	for k, v := range m {
		arr = append(arr, kv{k: k, v: v})
	}
	sort.Slice(arr, func(i, j int) bool {
		if arr[i].v == arr[j].v {
			return arr[i].k < arr[j].k
		}
		return arr[i].v > arr[j].v
	})
	out := make([]uint, 0, n)
	for i := 0; i < len(arr) && i < n; i++ {
		out = append(out, arr[i].k)
	}
	return out
}

func clamp01(v float64) float64 {
	if v < 0 {
		return 0
	}
	if v > 1 {
		return 1
	}
	return v
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
