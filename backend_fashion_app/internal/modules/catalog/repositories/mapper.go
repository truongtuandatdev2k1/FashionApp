package repositories

import "myfashion/internal/modules/catalog/entities"

// --- Brand Mappers ---

func (m *BrandModel) ToEntity() *entities.Brand {
	return &entities.Brand{
		ID:        m.ID,
		Name:      m.Name,
		LogoURL:   m.LogoURL,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
	}
}

func BrandEntityToModel(e *entities.Brand) *BrandModel {
	return &BrandModel{
		ID:      e.ID,
		Name:    e.Name,
		LogoURL: e.LogoURL,
	}
}

// --- Category Mappers ---

func (m *CategoryModel) ToEntity() *entities.Category {
	var products []entities.Product
	for _, p := range m.Products {
		// Chuyển đổi ProductModel sang Product entity mà không cần categories và styles để tránh vòng lặp vô hạn
		products = append(products, *p.ToEntity([]entities.Category{}, []entities.Style{}))
	}

	return &entities.Category{
		ID:        m.ID,
		Name:      m.Name,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Products:  products,
	}
}

func CategoryEntityToModel(e *entities.Category) *CategoryModel {
	var productModels []ProductModel
	for _, p := range e.Products {
		productModels = append(productModels, *ProductEntityToModel(&p))
	}

	return &CategoryModel{
		ID:        e.ID,
		Name:      e.Name,
		CreatedAt: e.CreatedAt,
		UpdatedAt: e.UpdatedAt,
		Products:  productModels,
	}
}

// --- Style Mappers ---

func (m *StyleModel) ToEntity() *entities.Style {
	var products []entities.Product
	for _, p := range m.Products {
		products = append(products, *p.ToEntity([]entities.Category{}, []entities.Style{}))
	}

	return &entities.Style{
		ID:        m.ID,
		Name:      m.Name,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Products:  products,
	}
}

func StyleEntityToModel(e *entities.Style) *StyleModel {
	var productModels []ProductModel
	for _, p := range e.Products {
		productModels = append(productModels, *ProductEntityToModel(&p))
	}

	return &StyleModel{
		ID:        e.ID,
		Name:      e.Name,
		CreatedAt: e.CreatedAt,
		UpdatedAt: e.UpdatedAt,
		Products:  productModels,
	}
}

// --- Product Mappers ---

func (m *ProductModel) ToEntity(categories []entities.Category, styles []entities.Style) *entities.Product {
	var brand *entities.Brand
	if m.Brand != nil {
		brand = m.Brand.ToEntity()
	}

	// Map variants (with embedded product color)
	variants := make([]entities.ProductVariant, 0, len(m.Variants))
	for _, vm := range m.Variants {
		// map product color images
		pcImages := make([]entities.ProductColorImage, 0, len(vm.ProductColor.Images))
		for _, im := range vm.ProductColor.Images {
			pcImages = append(pcImages, entities.ProductColorImage{
				ID:             im.ID,
				ProductColorID: im.ProductColorID,
				ImageURL:       im.ImageURL,
				SortOrder:      im.SortOrder,
				CreatedAt:      im.CreatedAt,
				UpdatedAt:      im.UpdatedAt,
			})
		}
		pc := entities.ProductColor{
			ID:        vm.ProductColor.ID,
			ProductID: vm.ProductColor.ProductID,
			ColorHex:  vm.ProductColor.ColorHex,
			ColorName: vm.ProductColor.ColorName,
			CreatedAt: vm.ProductColor.CreatedAt,
			UpdatedAt: vm.ProductColor.UpdatedAt,
			Images:    pcImages,
		}
		variants = append(variants, entities.ProductVariant{
			ID:             vm.ID,
			ProductID:      vm.ProductID,
			ProductColorID: vm.ProductColorID,
			ProductColor:   pc,
			SizeCode:       vm.SizeCode,
			Stock:          vm.Stock,
			Sku:            vm.Sku,
			CreatedAt:      vm.CreatedAt,
			UpdatedAt:      vm.UpdatedAt,
		})
	}

	return &entities.Product{
		ID:          m.ID,
		Brand:       brand,
		Categories:  categories,
		Styles:      styles,
		Name:        m.Name,
		Price:       m.Price,
		DiscountPct: m.DiscountPct,
		PriceAfter:  m.PriceAfter,
		IsHotTrend:  m.IsHotTrend,
		Status:      m.Status,
		AgeRange:    m.AgeRange,
		Description: m.Description,
		ImageURL:    m.ImageURL,
		Variants:    variants,
		CreatedAt:   m.CreatedAt,
		UpdatedAt:   m.UpdatedAt,
	}
}

func ProductEntityToModel(e *entities.Product) *ProductModel {
	var categoryModels []CategoryModel
	for _, cat := range e.Categories {
		categoryModels = append(categoryModels, *CategoryEntityToModel(&cat))
	}

	var styleModels []StyleModel
	for _, sty := range e.Styles {
		styleModels = append(styleModels, *StyleEntityToModel(&sty))
	}

	var brandID *uint
	if e.BrandID != nil {
		brandID = e.BrandID
	} else if e.Brand != nil {
		brandID = &e.Brand.ID
	}

	return &ProductModel{
		ID:          e.ID,
		Name:        e.Name,
		Price:       e.Price,
		DiscountPct: e.DiscountPct,
		PriceAfter:  e.PriceAfter,
		IsHotTrend:  e.IsHotTrend,
		Status:      e.Status,
		AgeRange:    e.AgeRange,
		Description: e.Description,
		ImageURL:    e.ImageURL,
		CreatedAt:   e.CreatedAt,
		UpdatedAt:   e.UpdatedAt,
		BrandID:     brandID,
		Categories:  categoryModels,
		Styles:      styleModels,
	}
}
