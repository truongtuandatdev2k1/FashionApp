package services

import (
	"context"
	"errors"
	"fmt"
	"myfashion/internal/modules/cart/api"
	"myfashion/internal/modules/cart/entities"
	"strings"
)

var (
	ErrProductNotFound   = errors.New("sản phẩm không tồn tại")
	ErrInsufficientStock = errors.New("số lượng tồn kho không đủ")
	ErrCartItemNotFound  = errors.New("sản phẩm không có trong giỏ hàng")
	ErrInvalidQuantity   = errors.New("số lượng không hợp lệ")
	ErrUnauthorized      = errors.New("không có quyền truy cập giỏ hàng này")
)

// VariantData represents the necessary product variant data for the cart.
type VariantData struct {
	VariantID uint
	ProductID uint
	Name      string  // Product Name
	ImageURL  string  // Product Image
	Price     float64 // Variant Price
	Stock     int     // Variant Stock
	SKU       string  // Variant SKU
	Color     string  // Variant Color Name
	ColorHex  string  // Variant Color Hex
	Size      string  // Variant Size
}

// ProductRepository interface to get product variant information.
type ProductRepository interface {
	GetVariantByID(ctx context.Context, id uint) (*VariantData, error)
	ResolveVariantByAttr(ctx context.Context, productID uint, colorHex, sizeCode string) (*VariantData, error)
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

// ChangeCartItemVariant changes color/size of a cart item, merging if target variant already exists.
func (s *CartService) ChangeCartItemVariant(ctx context.Context, userID, itemID uint, colorHex, sizeCode string) (*api.CartItemResponse, error) {
	// 1) Load item
	item, err := s.cartRepo.FindItemByID(ctx, itemID)
	if err != nil || item == nil {
		return nil, ErrCartItemNotFound
	}
	// 2) Ownership
	cart, err := s.cartRepo.GetCartByUserID(ctx, userID)
	if err != nil || cart.ID != item.CartID {
		return nil, ErrUnauthorized
	}
	// 3) Current variant -> to get productID and current attrs
	curVar, err := s.productRepo.GetVariantByID(ctx, item.ProductVariantID)
	if err != nil {
		return nil, ErrProductNotFound
	}
	// Normalize desired attrs
	if strings.TrimSpace(colorHex) == "" {
		colorHex = curVar.ColorHex
	}
	if strings.TrimSpace(sizeCode) == "" {
		sizeCode = curVar.Size
	}
	colorHex = strings.ToUpper(strings.TrimSpace(colorHex))
	sizeCode = strings.ToUpper(strings.TrimSpace(sizeCode))

	// 4) Resolve target variant by (productID, colorHex, sizeCode)
	targetVar, err := s.productRepo.ResolveVariantByAttr(ctx, curVar.ProductID, colorHex, sizeCode)
	if err != nil || targetVar == nil {
		return nil, ErrProductNotFound
	}
	// If same variant -> no-op
	if targetVar.VariantID == item.ProductVariantID {
		return s.buildCartItemResponse(item, curVar), nil
	}

	// 5) Merge logic
	existing, err := s.cartRepo.FindItemByCartAndVariant(ctx, cart.ID, targetVar.VariantID)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		// Merge quantities
		targetQty := existing.Quantity + item.Quantity
		if targetVar.Stock < targetQty {
			return nil, fmt.Errorf("%w: only %d items left", ErrInsufficientStock, targetVar.Stock)
		}
		// Update existing then delete current
		existing.Quantity = targetQty
		if err := s.cartRepo.UpdateItem(ctx, existing); err != nil {
			return nil, err
		}
		if err := s.cartRepo.DeleteItem(ctx, item.ID); err != nil {
			return nil, err
		}
		return s.buildCartItemResponse(existing, targetVar), nil
	}
	// No existing -> update current item to point to target variant
	if targetVar.Stock < item.Quantity {
		return nil, fmt.Errorf("%w: only %d items left", ErrInsufficientStock, targetVar.Stock)
	}
	item.ProductVariantID = targetVar.VariantID
	item.PriceSnapshot = targetVar.Price // reset snapshot to new variant price
	if err := s.cartRepo.UpdateItem(ctx, item); err != nil {
		return nil, err
	}
	return s.buildCartItemResponse(item, targetVar), nil
}

// AddToCart adds a product variant to the cart.
func (s *CartService) AddToCart(ctx context.Context, userID uint, req api.AddToCartRequest) (*api.CartItemResponse, error) {
	// 1. Resolve variant
	variant, err := s.productRepo.GetVariantByID(ctx, req.ProductVariantID)
	if err != nil {
		return nil, ErrProductNotFound
	}

	// 2. Get or create a cart for the user
	cart, err := s.cartRepo.GetOrCreateCartByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("could not retrieve cart: %w", err)
	}

	// 3. Merge-or-create logic with unique index safeguard
	return s.mergeOrCreateItem(ctx, cart.ID, variant, req.Quantity)
}

// mergeOrCreateItem merges quantity into existing item with same variant, or creates a new one.
// It is safe against duplicate rows thanks to a unique index (cart_id, product_variant_id) and retry on unique error.
func (s *CartService) mergeOrCreateItem(ctx context.Context, cartID uint, variant *VariantData, deltaQty int) (*api.CartItemResponse, error) {
	// Try find existing
	existingItem, err := s.cartRepo.FindItemByCartAndVariant(ctx, cartID, variant.VariantID)
	if err != nil {
		return nil, err
	}
	if existingItem != nil {
		newQuantity := existingItem.Quantity + deltaQty
		if variant.Stock < newQuantity {
			return nil, fmt.Errorf("%w: only %d items left, you already have %d in your cart", ErrInsufficientStock, variant.Stock, existingItem.Quantity)
		}
		existingItem.Quantity = newQuantity
		if err := s.cartRepo.UpdateItem(ctx, existingItem); err != nil {
			return nil, err
		}
		return s.buildCartItemResponse(existingItem, variant), nil
	}
	// Create new item
	if variant.Stock < deltaQty {
		return nil, fmt.Errorf("%w: only %d items left", ErrInsufficientStock, variant.Stock)
	}
	newItem := &entities.CartItem{CartID: cartID, ProductVariantID: variant.VariantID, Quantity: deltaQty, PriceSnapshot: variant.Price}
	if err := s.cartRepo.CreateItem(ctx, newItem); err != nil {
		// Handle unique constraint (race) by refetching and updating
		msg := fmt.Sprintf("%v", err)
		if containsUniqueViolation(msg) {
			// refetch and update
			existingItem, err := s.cartRepo.FindItemByCartAndVariant(ctx, cartID, variant.VariantID)
			if err != nil {
				return nil, err
			}
			if existingItem == nil {
				return nil, err // unexpected
			}
			newQuantity := existingItem.Quantity + deltaQty
			if variant.Stock < newQuantity {
				return nil, fmt.Errorf("%w: only %d items left, you already have %d in your cart", ErrInsufficientStock, variant.Stock, existingItem.Quantity)
			}
			existingItem.Quantity = newQuantity
			if err := s.cartRepo.UpdateItem(ctx, existingItem); err != nil {
				return nil, err
			}
			return s.buildCartItemResponse(existingItem, variant), nil
		}
		return nil, err
	}
	return s.buildCartItemResponse(newItem, variant), nil
}

func containsUniqueViolation(msg string) bool {
	// match common DB messages
	return (msg != "" && (containsIgnoreCase(msg, "duplicate") || containsIgnoreCase(msg, "unique")))
}

func containsIgnoreCase(s, sub string) bool {
	if len(s) < len(sub) {
		return false
	}
	// simple lower comparison without extra allocs
	ls, lsub := strings.ToLower(s), strings.ToLower(sub)
	return strings.Contains(ls, lsub)
}

// GetCart retrieves the full cart details for a user.
func (s *CartService) GetCart(ctx context.Context, userID uint) (*api.CartResponse, error) {
	// 1. Get the user's cart
	cart, err := s.cartRepo.GetOrCreateCartByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	// 2. Get all items in the cart
	items, err := s.cartRepo.GetItemsByCartID(ctx, cart.ID)
	if err != nil {
		return nil, err
	}

	// 3. Build the detailed response
	itemResponses := make([]api.CartItemResponse, 0, len(items))
	totalItems := 0
	totalAmount := 0.0
	hasIssues := false
	canCheckout := true

	for _, item := range items {
		variant, err := s.productRepo.GetVariantByID(ctx, item.ProductVariantID)
		if err != nil {
			// If variant not found, we can't process it. Mark as an issue.
			hasIssues = true
			canCheckout = false
			// TODO: Optionally create a special response for unavailable items
			continue
		}

		itemResp := s.buildCartItemResponse(&item, variant)
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

// UpdateCartItem updates the quantity of an item in the cart.
func (s *CartService) UpdateCartItem(ctx context.Context, userID, itemID uint, req api.UpdateCartItemRequest) (*api.CartItemResponse, error) {
	// 1. Get the cart item
	item, err := s.cartRepo.FindItemByID(ctx, itemID)
	if err != nil {
		return nil, ErrCartItemNotFound
	}

	// 2. Check ownership
	cart, err := s.cartRepo.GetCartByUserID(ctx, userID)
	if err != nil || cart.ID != item.CartID {
		return nil, ErrUnauthorized
	}

	// 3. Get product variant info and check stock
	variant, err := s.productRepo.GetVariantByID(ctx, item.ProductVariantID)
	if err != nil {
		return nil, ErrProductNotFound
	}

	if variant.Stock < req.Quantity {
		return nil, fmt.Errorf("%w: only %d items left", ErrInsufficientStock, variant.Stock)
	}

	// 4. Update quantity
	item.Quantity = req.Quantity
	if err := s.cartRepo.UpdateItem(ctx, item); err != nil {
		return nil, err
	}

	return s.buildCartItemResponse(item, variant), nil
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

// GetCartSummary gets a summary of the cart for checkout preparation.
func (s *CartService) GetCartSummary(ctx context.Context, userID uint) (*api.CartSummaryResponse, error) {
	cartResp, err := s.GetCart(ctx, userID)
	if err != nil {
		return nil, err
	}

	issues := []string{}
	for _, item := range cartResp.Items {
		if item.PriceChanged {
			issues = append(issues, fmt.Sprintf("Price for product '%s' (%s, %s) has changed.", item.Product.Name, item.Product.Color, item.Product.Size))
		}
		if item.StockIssue {
			issues = append(issues, fmt.Sprintf("Product '%s' (%s, %s) is out of stock. Only %d left.",
				item.Product.Name, item.Product.Color, item.Product.Size, item.Product.Stock))
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

// buildCartItemResponse builds the response for a cart item.
func (s *CartService) buildCartItemResponse(item *entities.CartItem, variant *VariantData) *api.CartItemResponse {
	currentPrice := variant.Price
	priceChanged := item.PriceSnapshot != currentPrice
	stockIssue := variant.Stock < item.Quantity

	return &api.CartItemResponse{
		ID:               item.ID,
		ProductVariantID: item.ProductVariantID,
		Product: api.ProductInfo{
			ProductID:    variant.ProductID,
			VariantID:    variant.VariantID,
			Name:         variant.Name,
			SKU:          variant.SKU,
			Color:        variant.Color,
			Size:         variant.Size,
			ImageURL:     variant.ImageURL,
			Stock:        variant.Stock,
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
