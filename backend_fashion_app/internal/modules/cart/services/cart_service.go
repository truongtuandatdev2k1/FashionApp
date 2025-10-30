package services

import (
	"context"
	"errors"
	"fmt"
	"myfashion/internal/modules/cart/api"
	"myfashion/internal/modules/cart/entities"
	catalogEntities "myfashion/internal/modules/catalog/entities"
)

var (
	ErrProductNotFound   = errors.New("sản phẩm không tồn tại")
	ErrInsufficientStock = errors.New("số lượng tồn kho không đủ")
	ErrCartItemNotFound  = errors.New("sản phẩm không có trong giỏ hàng")
	ErrInvalidQuantity   = errors.New("số lượng không hợp lệ")
	ErrUnauthorized      = errors.New("không có quyền truy cập giỏ hàng này")
)

// ProductRepository interface để lấy thông tin sản phẩm
type ProductRepository interface {
	GetByID(ctx context.Context, id uint) (*catalogEntities.Product, error)
}

type CartService struct {
	cartRepo    CartRepository
	productRepo ProductRepository
}

func NewCartService(cartRepo CartRepository, productRepo ProductRepository) *CartService {
	return &CartService{
		cartRepo:    cartRepo,
		productRepo: productRepo,
	}
}

// ========== BUSINESS LOGIC METHODS ==========

// AddToCart thêm sản phẩm vào giỏ hàng
func (s *CartService) AddToCart(ctx context.Context, userID uint, req api.AddToCartRequest) (*api.CartItemResponse, error) {
	// 1. Kiểm tra sản phẩm có tồn tại không
	product, err := s.productRepo.GetByID(ctx, req.ProductID)
	if err != nil {
		return nil, ErrProductNotFound
	}

	// 2. Kiểm tra tồn kho
	if product.Stock < req.Quantity {
		return nil, fmt.Errorf("%w: chỉ còn %d sản phẩm", ErrInsufficientStock, product.Stock)
	}

	// 3. Lấy hoặc tạo giỏ hàng cho user
	cart, err := s.cartRepo.GetOrCreateCartByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("không thể lấy giỏ hàng: %w", err)
	}

	// 4. Kiểm tra sản phẩm đã có trong giỏ chưa
	existingItem, err := s.cartRepo.FindItemByCartAndProduct(ctx, cart.ID, req.ProductID)
	if err != nil {
		return nil, err
	}

	if existingItem != nil {
		// Sản phẩm đã có -> cộng dồn số lượng
		newQuantity := existingItem.Quantity + req.Quantity

		// Kiểm tra lại tồn kho sau khi cộng dồn
		if product.Stock < newQuantity {
			return nil, fmt.Errorf("%w: chỉ còn %d sản phẩm, bạn đã có %d trong giỏ",
				ErrInsufficientStock, product.Stock, existingItem.Quantity)
		}

		existingItem.Quantity = newQuantity
		if err := s.cartRepo.UpdateItem(ctx, existingItem); err != nil {
			return nil, err
		}

		return s.buildCartItemResponse(ctx, existingItem, product), nil
	}

	// 5. Tạo item mới
	newItem := &entities.CartItem{
		CartID:        cart.ID,
		ProductID:     req.ProductID,
		Quantity:      req.Quantity,
		PriceSnapshot: product.PriceAfter, // Lưu giá hiện tại (sau giảm giá)
	}

	if err := s.cartRepo.CreateItem(ctx, newItem); err != nil {
		return nil, err
	}

	return s.buildCartItemResponse(ctx, newItem, product), nil
}

// GetCart lấy thông tin giỏ hàng đầy đủ
func (s *CartService) GetCart(ctx context.Context, userID uint) (*api.CartResponse, error) {
	// 1. Lấy giỏ hàng
	cart, err := s.cartRepo.GetOrCreateCartByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	// 2. Lấy tất cả items
	items, err := s.cartRepo.GetItemsByCartID(ctx, cart.ID)
	if err != nil {
		return nil, err
	}

	// 3. Build response với thông tin chi tiết
	itemResponses := make([]api.CartItemResponse, 0, len(items))
	totalItems := 0
	totalAmount := 0.0
	hasIssues := false
	canCheckout := true

	for _, item := range items {
		product, err := s.productRepo.GetByID(ctx, item.ProductID)
		if err != nil {
			// Sản phẩm không tồn tại -> bỏ qua hoặc đánh dấu
			continue
		}

		itemResp := s.buildCartItemResponse(ctx, &item, product)
		itemResponses = append(itemResponses, *itemResp)

		totalItems += item.Quantity
		totalAmount += itemResp.Subtotal

		if itemResp.PriceChanged || itemResp.StockIssue {
			hasIssues = true
		}

		if itemResp.StockIssue {
			canCheckout = false
		}
	}

	return &api.CartResponse{
		ID:          cart.ID,
		UserID:      cart.UserID,
		Items:       itemResponses,
		TotalItems:  totalItems,
		TotalAmount: totalAmount,
		HasIssues:   hasIssues,
		CanCheckout: canCheckout,
		CreatedAt:   cart.CreatedAt,
		UpdatedAt:   cart.UpdatedAt,
	}, nil
}

// UpdateCartItem cập nhật số lượng sản phẩm trong giỏ
func (s *CartService) UpdateCartItem(ctx context.Context, userID, itemID uint, req api.UpdateCartItemRequest) (*api.CartItemResponse, error) {
	// 1. Lấy item
	item, err := s.cartRepo.FindItemByID(ctx, itemID)
	if err != nil {
		return nil, ErrCartItemNotFound
	}

	// 2. Kiểm tra quyền sở hữu
	cart, err := s.cartRepo.GetCartByUserID(ctx, userID)
	if err != nil || cart.ID != item.CartID {
		return nil, ErrUnauthorized
	}

	// 3. Kiểm tra sản phẩm và tồn kho
	product, err := s.productRepo.GetByID(ctx, item.ProductID)
	if err != nil {
		return nil, ErrProductNotFound
	}

	if product.Stock < req.Quantity {
		return nil, fmt.Errorf("%w: chỉ còn %d sản phẩm", ErrInsufficientStock, product.Stock)
	}

	// 4. Cập nhật số lượng
	item.Quantity = req.Quantity
	if err := s.cartRepo.UpdateItem(ctx, item); err != nil {
		return nil, err
	}

	return s.buildCartItemResponse(ctx, item, product), nil
}

// RemoveCartItem xóa sản phẩm khỏi giỏ hàng
func (s *CartService) RemoveCartItem(ctx context.Context, userID, itemID uint) error {
	// 1. Lấy item
	item, err := s.cartRepo.FindItemByID(ctx, itemID)
	if err != nil {
		return ErrCartItemNotFound
	}

	// 2. Kiểm tra quyền sở hữu
	cart, err := s.cartRepo.GetCartByUserID(ctx, userID)
	if err != nil || cart.ID != item.CartID {
		return ErrUnauthorized
	}

	// 3. Xóa item
	return s.cartRepo.DeleteItem(ctx, itemID)
}

// ClearCart xóa toàn bộ giỏ hàng
func (s *CartService) ClearCart(ctx context.Context, userID uint) error {
	cart, err := s.cartRepo.GetCartByUserID(ctx, userID)
	if err != nil {
		return err
	}

	return s.cartRepo.ClearCart(ctx, cart.ID)
}

// GetCartSummary lấy tóm tắt giỏ hàng để chuẩn bị thanh toán
func (s *CartService) GetCartSummary(ctx context.Context, userID uint) (*api.CartSummaryResponse, error) {
	cartResp, err := s.GetCart(ctx, userID)
	if err != nil {
		return nil, err
	}

	issues := []string{}
	for _, item := range cartResp.Items {
		if item.PriceChanged {
			issues = append(issues, fmt.Sprintf("Giá sản phẩm '%s' đã thay đổi", item.Product.Name))
		}
		if item.StockIssue {
			issues = append(issues, fmt.Sprintf("Sản phẩm '%s' không đủ hàng (còn %d)",
				item.Product.Name, item.Product.Stock))
		}
	}

	return &api.CartSummaryResponse{
		Items:       cartResp.Items,
		TotalItems:  cartResp.TotalItems,
		TotalAmount: cartResp.TotalAmount,
		CanCheckout: cartResp.CanCheckout,
		Issues:      issues,
	}, nil
}

// ========== HELPER METHODS ==========

// buildCartItemResponse tạo response cho một cart item
func (s *CartService) buildCartItemResponse(ctx context.Context, item *entities.CartItem, product *catalogEntities.Product) *api.CartItemResponse {
	currentPrice := product.PriceAfter
	priceChanged := item.PriceSnapshot != currentPrice
	stockIssue := product.Stock < item.Quantity

	return &api.CartItemResponse{
		ID:        item.ID,
		ProductID: item.ProductID,
		Product: api.ProductInfo{
			ID:           product.ID,
			Name:         product.Name,
			ImageURL:     product.ImageURL,
			Stock:        product.Stock,
			CurrentPrice: currentPrice,
		},
		Quantity:      item.Quantity,
		PriceSnapshot: item.PriceSnapshot,
		CurrentPrice:  currentPrice,
		PriceChanged:  priceChanged,
		StockIssue:    stockIssue,
		Subtotal:      currentPrice * float64(item.Quantity),
		CreatedAt:     item.CreatedAt,
	}
}
