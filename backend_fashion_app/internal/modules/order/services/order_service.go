package services

import (
	"context"
	"time"

	"myfashion/internal/modules/order/entities"

	"github.com/google/uuid"
)

type OrderService struct {
	orderRepo   OrderRepository
	cartRepo    CartRepository
	addressRepo AddressRepository
	productRepo ProductRepository
}

func NewOrderService(
	orderRepo OrderRepository,
	cartRepo CartRepository,
	addressRepo AddressRepository,
	productRepo ProductRepository,
) *OrderService {
	return &OrderService{
		orderRepo:   orderRepo,
		cartRepo:    cartRepo,
		addressRepo: addressRepo,
		productRepo: productRepo,
	}
}

// CreateOrderInput represents input for creating an order
type CreateOrderInput struct {
	CustomerID       uint
	ShopID           uint
	ShippingName     string
	ShippingPhone    string
	ShippingAddress  string
	ShippingProvince string
	ShippingDistrict string
	ShippingWard     string
	PaymentMethod    entities.PaymentMethod
	ShippingFee      float64
	DiscountAmount   float64
	Note             string
	Items            []OrderItemInput
}

// OrderItemInput represents an order item input
type OrderItemInput struct {
	ProductID    uint
	ProductName  string
	ProductSKU   string
	ProductImage string
	Size         string
	Color        string
	Quantity     int
	Price        float64
}

// CreateOrderFromCart creates a new order from selected cart items
func (s *OrderService) CreateOrderFromCart(
	ctx context.Context,
	customerID uint,
	addressID uint,
	cartItemIDs []uint,
	paymentMethod entities.PaymentMethod,
	note string,
) (*entities.Order, error) {
	// 1. Validate input
	if len(cartItemIDs) == 0 {
		return nil, entities.ErrEmptyCart
	}

	// 2. Get address information
	address, err := s.addressRepo.FindByIDAndUserID(ctx, addressID, customerID)
	if err != nil {
		return nil, entities.ErrInvalidShippingAddress
	}

	// 3. Get cart items
	cartItems, err := s.cartRepo.FindItemsByIDs(ctx, cartItemIDs, customerID)
	if err != nil {
		return nil, err
	}

	if len(cartItems) == 0 {
		return nil, entities.ErrEmptyCart
	}

	// 4. Get product information and validate stock
	orderItems := make([]entities.OrderItem, 0, len(cartItems))

	for _, cartItem := range cartItems {
		product, err := s.productRepo.FindByID(ctx, cartItem.ProductID)
		if err != nil {
			return nil, err
		}

		// Check stock availability
		if product.Stock < cartItem.Quantity {
			return nil, entities.ErrEmptyCart // TODO: Create specific error for insufficient stock
		}

		// Create order item
		orderItem := entities.OrderItem{
			ID:           uuid.New(),
			ProductID:    product.ID,
			ProductName:  product.Name,
			ProductSKU:   "", // SKU không có trong Product entity
			ProductImage: product.ImageURL,
			Size:         "", // TODO: Add size/color to cart items
			Color:        "",
			Quantity:     cartItem.Quantity,
			Price:        product.PriceAfter,
			Subtotal:     product.PriceAfter * float64(cartItem.Quantity),
			CreatedAt:    time.Now(),
		}
		orderItems = append(orderItems, orderItem)
	}

	// 5. Create order (ShopID = 1 vì chỉ có 1 shop duy nhất)
	order := entities.NewOrder(customerID, 1)

	// Set shipping info from address
	order.ShippingName = address.RecipientName
	order.ShippingPhone = address.PhoneNumber

	fullAddress := address.AddressLine1
	if address.AddressLine2 != "" {
		fullAddress += ", " + address.AddressLine2
	}
	order.ShippingAddress = fullAddress
	order.ShippingWard = address.Ward
	order.ShippingDistrict = address.District
	order.ShippingProvince = address.City

	order.PaymentMethod = paymentMethod
	order.Note = note
	order.ShippingFee = 30000 // TODO: Calculate shipping fee based on location
	order.DiscountAmount = 0  // TODO: Apply discount/voucher if any
	order.Items = orderItems

	// Set order ID for all items
	for i := range order.Items {
		order.Items[i].OrderID = order.ID
	}

	// Calculate totals
	order.CalculateTotals()

	// 6. Save order to database
	if err := s.orderRepo.Create(ctx, order); err != nil {
		return nil, err
	}

	// 7. Decrement product stock
	for _, item := range orderItems {
		if err := s.productRepo.DecrementStock(ctx, item.ProductID, item.Quantity); err != nil {
			// TODO: Implement rollback mechanism
			return nil, err
		}
	}

	// 8. Remove items from cart
	if err := s.cartRepo.DeleteItems(ctx, cartItemIDs); err != nil {
		// Log error but don't fail the order creation
		// The order is already created successfully
	}

	return order, nil
}

// CreateOrder creates a new order (legacy method, kept for backward compatibility)
func (s *OrderService) CreateOrder(ctx context.Context, input CreateOrderInput) (*entities.Order, error) {
	// Validate input
	if len(input.Items) == 0 {
		return nil, entities.ErrEmptyCart
	}

	if input.ShippingAddress == "" || input.ShippingPhone == "" || input.ShippingName == "" {
		return nil, entities.ErrInvalidShippingAddress
	}

	// Create order
	order := entities.NewOrder(input.CustomerID, input.ShopID)
	order.ShippingName = input.ShippingName
	order.ShippingPhone = input.ShippingPhone
	order.ShippingAddress = input.ShippingAddress
	order.ShippingProvince = input.ShippingProvince
	order.ShippingDistrict = input.ShippingDistrict
	order.ShippingWard = input.ShippingWard
	order.PaymentMethod = input.PaymentMethod
	order.ShippingFee = input.ShippingFee
	order.DiscountAmount = input.DiscountAmount
	order.Note = input.Note

	// Add items
	order.Items = make([]entities.OrderItem, len(input.Items))
	for i, item := range input.Items {
		orderItem := entities.OrderItem{
			ID:           uuid.New(),
			OrderID:      order.ID,
			ProductID:    item.ProductID,
			ProductName:  item.ProductName,
			ProductSKU:   item.ProductSKU,
			ProductImage: item.ProductImage,
			Size:         item.Size,
			Color:        item.Color,
			Quantity:     item.Quantity,
			Price:        item.Price,
			Subtotal:     item.Price * float64(item.Quantity),
			CreatedAt:    time.Now(),
		}
		order.Items[i] = orderItem
	}

	// Calculate totals
	order.CalculateTotals()

	// Save to database
	if err := s.orderRepo.Create(ctx, order); err != nil {
		return nil, err
	}

	return order, nil
}

// GetOrderByID gets an order by ID
func (s *OrderService) GetOrderByID(ctx context.Context, orderID uuid.UUID, userID uint, isShop bool) (*entities.Order, error) {
	order, err := s.orderRepo.FindByID(ctx, orderID)
	if err != nil {
		return nil, err
	}

	// Check authorization
	if isShop {
		if order.ShopID != userID {
			return nil, entities.ErrUnauthorizedAccess
		}
	} else {
		if order.CustomerID != userID {
			return nil, entities.ErrUnauthorizedAccess
		}
	}

	return order, nil
}

// GetOrderByOrderNumber gets an order by order number
func (s *OrderService) GetOrderByOrderNumber(ctx context.Context, orderNumber string, userID uint, isShop bool) (*entities.Order, error) {
	order, err := s.orderRepo.FindByOrderNumber(ctx, orderNumber)
	if err != nil {
		return nil, err
	}

	// Check authorization
	if isShop {
		if order.ShopID != userID {
			return nil, entities.ErrUnauthorizedAccess
		}
	} else {
		if order.CustomerID != userID {
			return nil, entities.ErrUnauthorizedAccess
		}
	}

	return order, nil
}

// GetCustomerOrders gets all orders for a customer
func (s *OrderService) GetCustomerOrders(ctx context.Context, customerID uint, limit, offset int) ([]*entities.Order, int64, error) {
	return s.orderRepo.FindByCustomerID(ctx, customerID, limit, offset)
}

// GetCustomerOrdersByStatus gets customer orders by status
func (s *OrderService) GetCustomerOrdersByStatus(ctx context.Context, customerID uint, status entities.OrderStatus, limit, offset int) ([]*entities.Order, int64, error) {
	return s.orderRepo.FindByCustomerIDAndStatus(ctx, customerID, status, limit, offset)
}

// GetShopOrders gets all orders for a shop
func (s *OrderService) GetShopOrders(ctx context.Context, shopID uint, limit, offset int) ([]*entities.Order, int64, error) {
	return s.orderRepo.FindByShopID(ctx, shopID, limit, offset)
}

// ConfirmOrder confirms an order (shop action)
func (s *OrderService) ConfirmOrder(ctx context.Context, orderID uuid.UUID, shopID uint) (*entities.Order, error) {
	order, err := s.orderRepo.FindByID(ctx, orderID)
	if err != nil {
		return nil, err
	}

	// Check authorization
	if order.ShopID != shopID {
		return nil, entities.ErrUnauthorizedAccess
	}

	// Confirm order
	if err := order.Confirm(); err != nil {
		return nil, err
	}

	// Update in database
	if err := s.orderRepo.Update(ctx, order); err != nil {
		return nil, err
	}

	return order, nil
}

// UpdateOrderStatus updates order status (shop action)
func (s *OrderService) UpdateOrderStatus(ctx context.Context, orderID uuid.UUID, shopID uint, newStatus entities.OrderStatus) (*entities.Order, error) {
	order, err := s.orderRepo.FindByID(ctx, orderID)
	if err != nil {
		return nil, err
	}

	// Check authorization
	if order.ShopID != shopID {
		return nil, entities.ErrUnauthorizedAccess
	}

	// Update status
	if err := order.UpdateStatus(newStatus); err != nil {
		return nil, err
	}

	// Update in database
	if err := s.orderRepo.Update(ctx, order); err != nil {
		return nil, err
	}

	return order, nil
}

// CancelOrder cancels an order
func (s *OrderService) CancelOrder(ctx context.Context, orderID uuid.UUID, userID uint, reason string, isShop bool) (*entities.Order, error) {
	order, err := s.orderRepo.FindByID(ctx, orderID)
	if err != nil {
		return nil, err
	}

	// Check authorization
	if isShop {
		if order.ShopID != userID {
			return nil, entities.ErrUnauthorizedAccess
		}
	} else {
		if order.CustomerID != userID {
			return nil, entities.ErrUnauthorizedAccess
		}
	}

	// Cancel order
	if err := order.Cancel(reason); err != nil {
		return nil, err
	}

	// Update in database
	if err := s.orderRepo.Update(ctx, order); err != nil {
		return nil, err
	}

	return order, nil
}
