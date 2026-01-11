package services

import (
	"context"
	"errors"
	"myfashion/internal/modules/catalog/api"
	"myfashion/internal/modules/catalog/entities"
)

// CategoryService cung cấp nghiệp vụ cho danh mục sản phẩm.
type CategoryService struct {
	repo CategoryRepository
}

func NewCategoryService(repo CategoryRepository) *CategoryService {
	return &CategoryService{repo: repo}
}

func (s *CategoryService) CreateCategory(ctx context.Context, req api.CreateCategoryRequest) (*entities.Category, error) {
	category := &entities.Category{Name: req.Name}
	if err := s.repo.Create(ctx, category); err != nil {
		return nil, err
	}
	return category, nil
}

func (s *CategoryService) GetCategory(ctx context.Context, id uint) (*entities.Category, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *CategoryService) ListCategories(ctx context.Context) ([]*entities.Category, error) {
	return s.repo.GetAll(ctx)
}

func (s *CategoryService) UpdateCategory(ctx context.Context, id uint, req api.UpdateCategoryRequest) (*entities.Category, error) {
	category, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	category.Name = req.Name
	if err := s.repo.Update(ctx, category); err != nil {
		return nil, err
	}
	return category, nil
}

func (s *CategoryService) DeleteCategory(ctx context.Context, id uint) error {
	return s.repo.Delete(ctx, id)
}

// StyleService cung cấp nghiệp vụ cho phong cách sản phẩm.
type StyleService struct {
	repo StyleRepository
}

func NewStyleService(repo StyleRepository) *StyleService { return &StyleService{repo: repo} }

func (s *StyleService) CreateStyle(ctx context.Context, req api.CreateStyleRequest) (*entities.Style, error) {
	style := &entities.Style{Name: req.Name}
	if err := s.repo.Create(ctx, style); err != nil {
		return nil, err
	}
	return style, nil
}

func (s *StyleService) GetStyle(ctx context.Context, id uint) (*entities.Style, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *StyleService) ListStyles(ctx context.Context) ([]*entities.Style, error) {
	return s.repo.GetAll(ctx)
}

func (s *StyleService) UpdateStyle(ctx context.Context, id uint, req api.UpdateStyleRequest) (*entities.Style, error) {
	style, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	style.Name = req.Name
	if err := s.repo.Update(ctx, style); err != nil {
		return nil, err
	}
	return style, nil
}

func (s *StyleService) DeleteStyle(ctx context.Context, id uint) error { return s.repo.Delete(ctx, id) }

// ProductService cung cấp nghiệp vụ cho sản phẩm.
type ProductService struct {
	prodRepo  ProductRepository
	catRepo   CategoryRepository
	styleRepo StyleRepository
}

func NewProductService(prodRepo ProductRepository, catRepo CategoryRepository, styleRepo StyleRepository) *ProductService {
	return &ProductService{prodRepo: prodRepo, catRepo: catRepo, styleRepo: styleRepo}
}

func (s *ProductService) GetProduct(ctx context.Context, id uint) (*entities.Product, error) {
	return s.prodRepo.GetByID(ctx, id)
}

func (s *ProductService) ListProducts(ctx context.Context) ([]*entities.Product, error) {
	return s.prodRepo.GetAll(ctx)
}

func (s *ProductService) ListProductsPaginated(ctx context.Context, filter string, page, limit int, brandID uint) ([]*entities.Product, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	return s.prodRepo.GetAllPaginated(ctx, filter, page, limit, brandID)
}

func (s *ProductService) DeleteProduct(ctx context.Context, id uint) error {
	return s.prodRepo.Delete(ctx, id)
}

func (s *ProductService) AssignCategoriesToProduct(ctx context.Context, productID uint, categoryIDs []uint) error {
	product, err := s.prodRepo.GetByID(ctx, productID)
	if err != nil {
		return err
	}

	if len(categoryIDs) == 0 {
		product.Categories = []entities.Category{}
		return s.prodRepo.Update(ctx, product)
	}

	categories, err := s.catRepo.GetByIDs(ctx, categoryIDs)
	if err != nil {
		return err
	}

	product.Categories = categories
	return s.prodRepo.Update(ctx, product)
}

func (s *ProductService) AssignStylesToProduct(ctx context.Context, productID uint, styleIDs []uint) error {
	product, err := s.prodRepo.GetByID(ctx, productID)
	if err != nil {
		return err
	}

	if len(styleIDs) == 0 {
		product.Styles = []entities.Style{}
		return s.prodRepo.Update(ctx, product)
	}

	styles, err := s.styleRepo.GetByIDs(ctx, styleIDs)
	if err != nil {
		return err
	}

	product.Styles = styles
	return s.prodRepo.Update(ctx, product)
}

// BrandService provides brand-related operations.
type BrandService struct{ brandRepo BrandRepository }

func NewBrandService(brandRepo BrandRepository) *BrandService {
	return &BrandService{brandRepo: brandRepo}
}

func (s *BrandService) Create(ctx context.Context, name, logoURL string) (*entities.Brand, error) {
	if name == "" {
		return nil, errors.New("brand name is required")
	}
	brand := &entities.Brand{Name: name, LogoURL: logoURL}
	if err := s.brandRepo.Create(ctx, brand); err != nil {
		return nil, err
	}
	return brand, nil
}

func (s *BrandService) GetByID(ctx context.Context, id uint) (*entities.Brand, error) {
	return s.brandRepo.GetByID(ctx, id)
}

func (s *BrandService) List(ctx context.Context, q string, limit, offset int) ([]*entities.Brand, int64, error) {
	return s.brandRepo.List(ctx, q, limit, offset)
}

func (s *BrandService) Update(ctx context.Context, id uint, name, logoURL string) (*entities.Brand, error) {
	brand, err := s.brandRepo.GetByID(ctx, id)
	if err != nil {
		return nil, errors.New("brand not found")
	}
	if name != "" {
		brand.Name = name
	}
	if logoURL != "" {
		brand.LogoURL = logoURL
	}
	if err := s.brandRepo.Update(ctx, brand); err != nil {
		return nil, err
	}
	return brand, nil
}

func (s *BrandService) Delete(ctx context.Context, id uint) error {
	if _, err := s.brandRepo.GetByID(ctx, id); err != nil {
		return errors.New("brand not found")
	}
	return s.brandRepo.Delete(ctx, id)
}

// --- Color Service ---

type ColorService struct{ repo ColorRepository }

func NewColorService(repo ColorRepository) *ColorService { return &ColorService{repo: repo} }

func (s *ColorService) Create(ctx context.Context, req api.CreateColorRequest) (*entities.Color, error) {
	color := &entities.Color{Name: req.Name, HexCode: req.HexCode}
	if err := s.repo.Create(ctx, color); err != nil {
		return nil, err
	}
	return color, nil
}

func (s *ColorService) GetAll(ctx context.Context) ([]*entities.Color, error) {
	return s.repo.GetAll(ctx)
}

func (s *ColorService) Update(ctx context.Context, id uint, req api.UpdateColorRequest) (*entities.Color, error) {
	color, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if req.Name != "" {
		color.Name = req.Name
	}
	if req.HexCode != "" {
		color.HexCode = req.HexCode
	}
	if err := s.repo.Update(ctx, color); err != nil {
		return nil, err
	}
	return color, nil
}

func (s *ColorService) Delete(ctx context.Context, id uint) error { return s.repo.Delete(ctx, id) }
