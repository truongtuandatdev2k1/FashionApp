package repositories

import (
	"myfashion/internal/modules/order/entities"
)

// toEntity converts OrderModel to entities.Order
func toEntity(m *OrderModel) *entities.Order {
	if m == nil {
		return nil
	}

	order := &entities.Order{
		ID:               m.ID,
		OrderNumber:      m.OrderNumber,
		CustomerID:       m.CustomerID,
		ShopID:           m.ShopID,
		ShippingName:     m.ShippingName,
		ShippingPhone:    m.ShippingPhone,
		ShippingAddress:  m.ShippingAddress,
		ShippingProvince: m.ShippingProvince,
		ShippingDistrict: m.ShippingDistrict,
		ShippingWard:     m.ShippingWard,
		TotalAmount:      m.TotalAmount,
		ShippingFee:      m.ShippingFee,
		DiscountAmount:   m.DiscountAmount,
		FinalAmount:      m.FinalAmount,
		PaymentMethod:    entities.PaymentMethod(m.PaymentMethod),
		PaymentStatus:    entities.PaymentStatus(m.PaymentStatus),
		Status:           entities.OrderStatus(m.Status),
		Note:             m.Note,
		CancelReason:     m.CancelReason,
		CreatedAt:        m.CreatedAt,
		UpdatedAt:        m.UpdatedAt,
		ConfirmedAt:      m.ConfirmedAt,
		ShippedAt:        m.ShippedAt,
		DeliveredAt:      m.DeliveredAt,
		CancelledAt:      m.CancelledAt,
	}

	// Convert items
	order.Items = make([]entities.OrderItem, len(m.Items))
	for i, item := range m.Items {
		order.Items[i] = toItemEntity(&item)
	}

	return order
}

// toItemEntity converts OrderItemModel to entities.OrderItem
func toItemEntity(m *OrderItemModel) entities.OrderItem {
	return entities.OrderItem{
		ID:           m.ID,
		OrderID:      m.OrderID,
		ProductID:    m.ProductID,
		ProductName:  m.ProductName,
		ProductSKU:   m.ProductSKU,
		ProductImage: m.ProductImage,
		Size:         m.Size,
		Color:        m.Color,
		Quantity:     m.Quantity,
		Price:        m.Price,
		Subtotal:     m.Subtotal,
		CreatedAt:    m.CreatedAt,
	}
}

// toModel converts entities.Order to OrderModel
func toModel(e *entities.Order) *OrderModel {
	if e == nil {
		return nil
	}

	model := &OrderModel{
		ID:               e.ID,
		OrderNumber:      e.OrderNumber,
		CustomerID:       e.CustomerID,
		ShopID:           e.ShopID,
		ShippingName:     e.ShippingName,
		ShippingPhone:    e.ShippingPhone,
		ShippingAddress:  e.ShippingAddress,
		ShippingProvince: e.ShippingProvince,
		ShippingDistrict: e.ShippingDistrict,
		ShippingWard:     e.ShippingWard,
		TotalAmount:      e.TotalAmount,
		ShippingFee:      e.ShippingFee,
		DiscountAmount:   e.DiscountAmount,
		FinalAmount:      e.FinalAmount,
		PaymentMethod:    string(e.PaymentMethod),
		PaymentStatus:    string(e.PaymentStatus),
		Status:           string(e.Status),
		Note:             e.Note,
		CancelReason:     e.CancelReason,
		CreatedAt:        e.CreatedAt,
		UpdatedAt:        e.UpdatedAt,
		ConfirmedAt:      e.ConfirmedAt,
		ShippedAt:        e.ShippedAt,
		DeliveredAt:      e.DeliveredAt,
		CancelledAt:      e.CancelledAt,
	}

	// Convert items
	model.Items = make([]OrderItemModel, len(e.Items))
	for i, item := range e.Items {
		model.Items[i] = toItemModel(&item)
	}

	return model
}

// toItemModel converts entities.OrderItem to OrderItemModel
func toItemModel(e *entities.OrderItem) OrderItemModel {
	return OrderItemModel{
		ID:           e.ID,
		OrderID:      e.OrderID,
		ProductID:    e.ProductID,
		ProductName:  e.ProductName,
		ProductSKU:   e.ProductSKU,
		ProductImage: e.ProductImage,
		Size:         e.Size,
		Color:        e.Color,
		Quantity:     e.Quantity,
		Price:        e.Price,
		Subtotal:     e.Subtotal,
		CreatedAt:    e.CreatedAt,
	}
}
