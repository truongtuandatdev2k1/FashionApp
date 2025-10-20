package repositories

import "myfashion/internal/modules/catalog/entities"

// --- Category Mappers ---

func (m *CategoryModel) ToEntity() *entities.Category {
	return &entities.Category{
		ID:        m.ID,
		Name:      m.Name,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
	}
}

func CategoryEntityToModel(e *entities.Category) *CategoryModel {
	return &CategoryModel{
		ID:        e.ID,
		Name:      e.Name,
		CreatedAt: e.CreatedAt,
		UpdatedAt: e.UpdatedAt,
	}
}

// --- Style Mappers ---

func (m *StyleModel) ToEntity() *entities.Style {
	return &entities.Style{
		ID:        m.ID,
		Name:      m.Name,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
	}
}

func StyleEntityToModel(e *entities.Style) *StyleModel {
	return &StyleModel{
		ID:        e.ID,
		Name:      e.Name,
		CreatedAt: e.CreatedAt,
		UpdatedAt: e.UpdatedAt,
	}
}

// --- Product Mappers ---

func (m *ProductModel) ToEntity(categories []entities.Category, styles []entities.Style, images []entities.ProductImage) *entities.Product {
	return &entities.Product{
		ID:          m.ID,
		CategoryIDs: m.CategoryIDs,
		StyleIDs:    m.StyleIDs,
		Categories:  categories,
		Styles:      styles,
		Name:        m.Name,
		Price:       m.Price,
		DiscountPct: m.DiscountPct,
		PriceAfter:  m.PriceAfter,
		Color:       m.Color,
		AgeRange:    m.AgeRange,
		Description: m.Description,
		ImageURL:    m.ImageURL,
		Images:      images,
		CreatedAt:   m.CreatedAt,
		UpdatedAt:   m.UpdatedAt,
	}
}

func ProductEntityToModel(e *entities.Product) *ProductModel {
	return &ProductModel{
		ID:          e.ID,
		CategoryIDs: e.CategoryIDs,
		StyleIDs:    e.StyleIDs,
		Name:        e.Name,
		Price:       e.Price,
		DiscountPct: e.DiscountPct,
		PriceAfter:  e.PriceAfter,
		Color:       e.Color,
		AgeRange:    e.AgeRange,
		Description: e.Description,
		ImageURL:    e.ImageURL,
		CreatedAt:   e.CreatedAt,
		UpdatedAt:   e.UpdatedAt,
	}
}

// --- Product Image Mappers ---

func (m *ProductImageModel) ToEntity() *entities.ProductImage {
	return &entities.ProductImage{
		ID:        m.ID,
		ProductID: m.ProductID,
		URL:       m.URL,
		CreatedAt: m.CreatedAt,
	}
}

func ProductImageEntityToModel(e *entities.ProductImage) *ProductImageModel {
	return &ProductImageModel{
		ID:        e.ID,
		ProductID: e.ProductID,
		URL:       e.URL,
		CreatedAt: e.CreatedAt,
	}
}
