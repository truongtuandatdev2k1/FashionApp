package entities

import (
	"time"
)

// PromotionType định nghĩa các loại khuyến mãi
type PromotionType string

const (
	TypeOrderFixed      PromotionType = "order_fixed"
	TypeOrderPercentage PromotionType = "order_percentage"
	TypeShippingFixed   PromotionType = "shipping_fixed"
	TypeFreeShipping    PromotionType = "free_shipping"
)

// TargetGroup định nghĩa nhóm khách hàng mục tiêu
type TargetGroup string

const (
	TargetAllCustomers  TargetGroup = "all"
	TargetNewCustomers  TargetGroup = "new_customer"
	TargetSpecificUsers TargetGroup = "specific_users"
	TargetCustomerTier  TargetGroup = "customer_tier"
)

// Promotion là entity chính cho một chương trình khuyến mãi
type Promotion struct {
	ID              uint          // ID của khuyến mãi
	Code            string        // Mã khuyến mãi duy nhất, ví dụ: "SALE50", "FREESHIP"
	Name            string        // Tên chương trình, ví dụ: "Giảm giá 50k"
	Description     string        // Mô tả chi tiết về chương trình
	Type            PromotionType // Loại khuyến mãi: 'order_fixed', 'order_percentage', 'shipping_fixed', 'free_shipping'
	Value           float64       // Giá trị của khuyến mãi (ví dụ: 50000 hoặc 10 cho 10%)
	MaxDiscount     *float64      // Số tiền giảm tối đa, chỉ áp dụng cho 'order_percentage' và 'shipping_fixed'
	MinOrderValue   float64       // Giá trị đơn hàng tối thiểu (chưa tính phí ship) để được áp dụng mã
	StartDate       time.Time     // Ngày bắt đầu hiệu lực
	EndDate         time.Time     // Ngày kết thúc hiệu lực
	UsageLimit      int           // Tổng số lượt sử dụng tối đa của mã này (0 = không giới hạn)
	UsageCount      int           // Số lượt đã được sử dụng
	UserUsageLimit  int           // Số lần mỗi người dùng được sử dụng mã này (0 = không giới hạn)
	IsActive        bool          // Mã có đang được kích hoạt hay không
	IsStackable     bool          // Có cho phép dùng chung (cộng dồn) với các mã khuyến mãi khác không
	TargetGroup     TargetGroup   // Nhóm khách hàng mục tiêu: 'all', 'new_customer', 'specific_users', 'customer_tier'
	ApplicableTiers []string      // Danh sách các hạng được áp dụng (khi TargetGroup = 'customer_tier'), ví dụ: ["gold", "silver"]
	ApplicableUsers []uint        // Danh sách user ID được áp dụng (khi TargetGroup = 'specific_users')
	CreatedAt       time.Time
	UpdatedAt       time.Time
}
