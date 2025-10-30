# 🛒 Cart Module

Module Cart quản lý giỏ hàng của người dùng trong hệ thống MyFashion.

## 📋 Tính năng

- ✅ Thêm sản phẩm vào giỏ hàng
- ✅ Cập nhật số lượng sản phẩm
- ✅ Xóa sản phẩm khỏi giỏ hàng
- ✅ Xóa toàn bộ giỏ hàng
- ✅ Xem giỏ hàng với thông tin chi tiết
- ✅ Kiểm tra giá thay đổi (price snapshot vs current price)
- ✅ Kiểm tra tồn kho trước khi checkout
- ✅ Tóm tắt giỏ hàng để chuẩn bị thanh toán

## 🗂️ Cấu trúc

```
cart/
├── entities/           # Domain entities
│   ├── cart.go        # Cart entity
│   └── cart_item.go   # CartItem entity
├── api/               # DTOs (Request/Response)
│   └── cart_dto.go
├── repositories/      # Data access layer
│   ├── models.go      # Database models
│   ├── mapper.go      # Entity <-> Model mappers
│   └── cart_gorm.go   # GORM implementation
├── services/          # Business logic
│   ├── ports.go       # Repository interfaces
│   └── cart_service.go
├── controllers/       # HTTP handlers
│   └── cart_controller.go
├── module_routes.go   # Route registration
├── migrate.go         # Database migration
└── README.md          # This file
```

## 🔌 API Endpoints

Tất cả endpoints yêu cầu **Bearer Token** trong header `Authorization`.

### 1. Lấy giỏ hàng
```http
GET /api/v1/cart
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "user_id": 123,
    "items": [
      {
        "id": 1,
        "product_id": 10,
        "product": {
          "id": 10,
          "name": "Áo thun nam",
          "image_url": "/uploads/products/123.jpg",
          "stock": 50,
          "current_price": 199000
        },
        "quantity": 2,
        "price_snapshot": 199000,
        "current_price": 199000,
        "price_changed": false,
        "stock_issue": false,
        "subtotal": 398000,
        "created_at": "2025-10-21T09:00:00Z"
      }
    ],
    "total_items": 2,
    "total_amount": 398000,
    "has_issues": false,
    "can_checkout": true,
    "created_at": "2025-10-20T10:00:00Z",
    "updated_at": "2025-10-21T09:00:00Z"
  }
}
```

### 2. Thêm sản phẩm vào giỏ
```http
POST /api/v1/cart/items
Content-Type: application/json

{
  "product_id": 10,
  "quantity": 2
}
```

**Response:** `201 Created` với thông tin `CartItemResponse`

### 3. Cập nhật số lượng sản phẩm
```http
PUT /api/v1/cart/items/{id}
Content-Type: application/json

{
  "quantity": 5
}
```

**Response:** `200 OK` với thông tin `CartItemResponse` đã cập nhật

### 4. Xóa sản phẩm khỏi giỏ
```http
DELETE /api/v1/cart/items/{id}
```

**Response:** `200 OK`

### 5. Xóa toàn bộ giỏ hàng
```http
DELETE /api/v1/cart
```

**Response:** `200 OK`

### 6. Tóm tắt giỏ hàng (để checkout)
```http
GET /api/v1/cart/summary
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "items": [...],
    "total_items": 5,
    "total_amount": 1500000,
    "can_checkout": true,
    "issues": []
  }
}
```

Nếu có vấn đề (giá thay đổi hoặc hết hàng):
```json
{
  "can_checkout": false,
  "issues": [
    "Giá sản phẩm 'Áo thun nam' đã thay đổi",
    "Sản phẩm 'Quần jean' không đủ hàng (còn 3)"
  ]
}
```

## 🔐 Authentication

Tất cả endpoints yêu cầu JWT token hợp lệ:

```http
Authorization: Bearer <your_jwt_token>
```

## 🎯 Business Logic

### Price Tracking
- Khi thêm sản phẩm vào giỏ, giá hiện tại (`PriceAfter`) được lưu vào `price_snapshot`
- Khi xem giỏ hàng, hệ thống so sánh `price_snapshot` với giá hiện tại
- Nếu giá thay đổi, `price_changed = true` để thông báo cho người dùng

### Stock Validation
- Khi thêm/cập nhật sản phẩm, hệ thống kiểm tra tồn kho
- Nếu số lượng trong giỏ > tồn kho, `stock_issue = true`
- Người dùng không thể checkout nếu có `stock_issue`

### Cart Management
- Mỗi user chỉ có **1 giỏ hàng** duy nhất
- Nếu thêm sản phẩm đã có trong giỏ → **cộng dồn số lượng**
- Giỏ hàng được tạo tự động khi user thêm sản phẩm lần đầu

## 📊 Database Schema

### Table: `carts`
| Column     | Type      | Description           |
|------------|-----------|-----------------------|
| id         | uint      | Primary key           |
| user_id    | uint      | Foreign key (unique)  |
| created_at | timestamp |                       |
| updated_at | timestamp |                       |

### Table: `cart_items`
| Column         | Type          | Description                    |
|----------------|---------------|--------------------------------|
| id             | uint          | Primary key                    |
| cart_id        | uint          | Foreign key                    |
| product_id     | uint          | Foreign key                    |
| quantity       | int           | Số lượng                       |
| price_snapshot | decimal(10,2) | Giá lúc thêm vào giỏ          |
| created_at     | timestamp     |                                |
| updated_at     | timestamp     |                                |

## 🧪 Testing

### Thêm sản phẩm vào giỏ
```bash
curl -X POST http://localhost:8080/api/v1/cart/items \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "quantity": 2
  }'
```

### Xem giỏ hàng
```bash
curl -X GET http://localhost:8080/api/v1/cart \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Cập nhật số lượng
```bash
curl -X PUT http://localhost:8080/api/v1/cart/items/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 5
  }'
```

## 🚀 Next Steps

Module Cart đã sẵn sàng để tích hợp với:
- **Order Module**: Chuyển đổi giỏ hàng thành đơn hàng
- **Payment Module**: Xử lý thanh toán
- **Notification Module**: Thông báo khi giá thay đổi hoặc hết hàng

## 📝 Notes

- Giỏ hàng **không tự động xóa** sau khi checkout (cần xử lý trong Order module)
- Giá trong giỏ hàng luôn sử dụng `PriceAfter` (giá sau giảm giá)
- Hệ thống hỗ trợ **concurrent requests** an toàn nhờ GORM transactions

