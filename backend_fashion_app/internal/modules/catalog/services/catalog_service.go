package services

import (
	"context"
	"myfashion/internal/modules/catalog/api"
	"myfashion/internal/modules/catalog/entities"
)

// CatalogService provides catalog-related services.
type CatalogService struct {
	catRepo   CategoryRepository
	styleRepo StyleRepository
	prodRepo  ProductRepository
}

// NewCatalogService creates a new CatalogService.
func NewCatalogService(catRepo CategoryRepository, styleRepo StyleRepository, prodRepo ProductRepository) *CatalogService {
	return &CatalogService{
		catRepo:   catRepo,
		styleRepo: styleRepo,
		prodRepo:  prodRepo,
	}
}

// --- Category Services ---

func (s *CatalogService) CreateCategory(ctx context.Context, req api.CreateCategoryRequest) (*entities.Category, error) {
	category := &entities.Category{
		Name: req.Name,
	}
	if err := s.catRepo.Create(ctx, category); err != nil {
		return nil, err
	}
	return category, nil
}

func (s *CatalogService) GetCategory(ctx context.Context, id uint) (*entities.Category, error) {
	return s.catRepo.GetByID(ctx, id)
}

func (s *CatalogService) ListCategories(ctx context.Context) ([]*entities.Category, error) {
	return s.catRepo.GetAll(ctx)
}

func (s *CatalogService) UpdateCategory(ctx context.Context, id uint, req api.UpdateCategoryRequest) (*entities.Category, error) {
	category, err := s.catRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	category.Name = req.Name
	if err := s.catRepo.Update(ctx, category); err != nil {
		return nil, err
	}
	return category, nil
}

func (s *CatalogService) DeleteCategory(ctx context.Context, id uint) error {
	return s.catRepo.Delete(ctx, id)
}

// --- Style Services ---

func (s *CatalogService) CreateStyle(ctx context.Context, req api.CreateStyleRequest) (*entities.Style, error) {
	style := &entities.Style{
		Name: req.Name,
	}
	if err := s.styleRepo.Create(ctx, style); err != nil {
		return nil, err
	}
	return style, nil
}

func (s *CatalogService) GetStyle(ctx context.Context, id uint) (*entities.Style, error) {
	return s.styleRepo.GetByID(ctx, id)
}

func (s *CatalogService) ListStyles(ctx context.Context) ([]*entities.Style, error) {
	return s.styleRepo.GetAll(ctx)
}

func (s *CatalogService) UpdateStyle(ctx context.Context, id uint, req api.UpdateStyleRequest) (*entities.Style, error) {
	style, err := s.styleRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	style.Name = req.Name
	if err := s.styleRepo.Update(ctx, style); err != nil {
		return nil, err
	}
	return style, nil
}

func (s *CatalogService) DeleteStyle(ctx context.Context, id uint) error {
	return s.styleRepo.Delete(ctx, id)
}

// --- Product Services ---

func (s *CatalogService) CreateProduct(ctx context.Context, req api.CreateProductRequest) (*entities.Product, error) {
	priceAfter := req.Price * (1 - float64(req.DiscountPct)/100)

	product := &entities.Product{
		CategoryIDs: req.CategoryIDs,
		StyleIDs:    req.StyleIDs,
		Name:        req.Name,
		Price:       req.Price,
		DiscountPct: req.DiscountPct,
		PriceAfter:  priceAfter,
		Color:       req.Color,
		AgeRange:    req.AgeRange,
		Description: req.Description,
	}

	if err := s.prodRepo.Create(ctx, product); err != nil {
		return nil, err
	}
	return s.prodRepo.GetByID(ctx, product.ID)
}

func (s *CatalogService) GetProduct(ctx context.Context, id uint) (*entities.Product, error) {
	return s.prodRepo.GetByID(ctx, id)
}

func (s *CatalogService) ListProducts(ctx context.Context) ([]*entities.Product, error) {
	return s.prodRepo.GetAll(ctx)
}

func (s *CatalogService) UpdateProduct(ctx context.Context, id uint, req api.UpdateProductRequest) (*entities.Product, error) {
	product, err := s.prodRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	// Track if price or discount changed to recalculate price_after
	priceChanged := false
	discountChanged := false

	// Update fields if they are provided in the request
	if req.Name != "" {
		product.Name = req.Name
	}
	if req.CategoryIDs != "" {
		product.CategoryIDs = req.CategoryIDs
	}
	if req.StyleIDs != "" {
		product.StyleIDs = req.StyleIDs
	}
	if req.Price > 0 {
		product.Price = req.Price
		priceChanged = true
	}

	// Only update discount if explicitly provided (pointer is not nil)
	if req.DiscountPct != nil {
		product.DiscountPct = *req.DiscountPct
		discountChanged = true
	}

	// Recalculate price_after only if price or discount changed
	if priceChanged || discountChanged {
		product.PriceAfter = product.Price * (1 - float64(product.DiscountPct)/100)
	}

	if req.Color != "" {
		product.Color = req.Color
	}
	if req.AgeRange != "" {
		product.AgeRange = req.AgeRange
	}
	if req.Description != "" {
		product.Description = req.Description
	}
	if req.ImageURL != "" {
		product.ImageURL = req.ImageURL
	}

	if err := s.prodRepo.Update(ctx, product); err != nil {
		return nil, err
	}
	return s.prodRepo.GetByID(ctx, id)
}

func (s *CatalogService) DeleteProduct(ctx context.Context, id uint) error {
	return s.prodRepo.Delete(ctx, id)
}

func (s *CatalogService) AddProductImages(ctx context.Context, productID uint, imageURLs []string) ([]entities.ProductImage, error) {
	var images []entities.ProductImage
	for _, url := range imageURLs {
		image := &entities.ProductImage{
			ProductID: productID,
			URL:       url,
		}
		if err := s.prodRepo.CreateImage(ctx, image); err != nil {
			// In a real app, you might want to handle this more gracefully (e.g., transaction)
			return nil, err
		}
		images = append(images, *image)
	}
	return images, nil
}
