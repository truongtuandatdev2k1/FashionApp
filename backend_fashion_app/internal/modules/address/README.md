# Address Module

Module quản lý địa chỉ giao hàng cho người dùng trong hệ thống Fashion App.

## Tính năng

- ✅ Quản lý nhiều địa chỉ cho mỗi user
- ✅ Địa chỉ mặc định (default address)
- ✅ Phân loại địa chỉ (home, office, other)
- ✅ Validation số điện thoại Việt Nam
- ✅ Cấu trúc địa chỉ theo chuẩn Việt Nam (Phường/Xã, Quận/Huyện, Tỉnh/Thành phố)

## Database Schema

```sql
CREATE TABLE addresses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    recipient_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(500) NOT NULL,
    address_line2 VARCHAR(500),
    ward VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address_type VARCHAR(20) NOT NULL DEFAULT 'home',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_user_default (user_id, is_default),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## API Endpoints

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/api/v1/addresses` | Lấy danh sách địa chỉ | ✅ |
| GET | `/api/v1/addresses/default` | Lấy địa chỉ mặc định | ✅ |
| GET | `/api/v1/addresses/{id}` | Lấy chi tiết địa chỉ | ✅ |
| POST | `/api/v1/addresses` | Tạo địa chỉ mới | ✅ |
| PUT | `/api/v1/addresses/{id}` | Cập nhật địa chỉ | ✅ |
| DELETE | `/api/v1/addresses/{id}` | Xóa địa chỉ | ✅ |
| PATCH | `/api/v1/addresses/{id}/set-default` | Set làm địa chỉ mặc định | ✅ |

## Business Logic

### 1. Tạo địa chỉ mới
- Địa chỉ đầu tiên tự động được set làm mặc định
- Nếu user chọn set làm mặc định, bỏ mặc định của địa chỉ cũ
- Validate số điện thoại (10 số, bắt đầu bằng 0)

### 2. Xóa địa chỉ
- Không cho phép xóa địa chỉ duy nhất
- Nếu xóa địa chỉ mặc định, tự động set địa chỉ khác làm mặc định

### 3. Set địa chỉ mặc định
- Chỉ có 1 địa chỉ mặc định duy nhất cho mỗi user
- Khi set địa chỉ mới làm mặc định, bỏ mặc định của địa chỉ cũ

## Request/Response Examples

### Create Address
```json
POST /api/v1/addresses
{
  "recipient_name": "Nguyễn Văn A",
  "phone_number": "0912345678",
  "address_line1": "123 Nguyễn Huệ",
  "address_line2": "Tầng 5, Tòa nhà ABC",
  "ward": "Phường Bến Nghé",
  "district": "Quận 1",
  "city": "Hồ Chí Minh",
  "address_type": "home",
  "is_default": true
}
```

### Response
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 123,
    "recipient_name": "Nguyễn Văn A",
    "phone_number": "0912345678",
    "address_line1": "123 Nguyễn Huệ",
    "address_line2": "Tầng 5, Tòa nhà ABC",
    "ward": "Phường Bến Nghé",
    "district": "Quận 1",
    "city": "Hồ Chí Minh",
    "full_address": "123 Nguyễn Huệ, Tầng 5, Tòa nhà ABC, Phường Bến Nghé, Quận 1, Hồ Chí Minh",
    "address_type": "home",
    "is_default": true,
    "created_at": "2025-10-21T10:00:00Z",
    "updated_at": "2025-10-21T10:00:00Z"
  }
}
```

## Validation Rules

- `recipient_name`: Bắt buộc
- `phone_number`: Bắt buộc, 10 số, bắt đầu bằng 0
- `address_line1`: Bắt buộc
- `ward`: Bắt buộc
- `district`: Bắt buộc
- `city`: Bắt buộc
- `address_type`: Phải là `home`, `office`, hoặc `other`

## Error Codes

| Error | HTTP Status | Message |
|-------|-------------|---------|
| `ErrAddressNotFound` | 404 | address not found |
| `ErrUnauthorizedAccess` | 403 | unauthorized access to address |
| `ErrCannotDeleteLastAddress` | 400 | cannot delete the last address |
| `ErrInvalidPhoneNumber` | 400 | invalid phone number format |
| `ErrRecipientNameRequired` | 400 | recipient name is required |
| `ErrPhoneNumberRequired` | 400 | phone number is required |
| `ErrAddressLine1Required` | 400 | address line 1 is required |
| `ErrWardRequired` | 400 | ward is required |
| `ErrDistrictRequired` | 400 | district is required |
| `ErrCityRequired` | 400 | city is required |

## Integration với Order Module

Khi tạo đơn hàng, module Order có thể:
1. Lấy địa chỉ mặc định của user
2. Cho phép user chọn địa chỉ khác
3. Snapshot thông tin địa chỉ vào order (để tránh thay đổi sau này)

```go
// Example integration
defaultAddress, err := addressService.GetDefault(userID)
if err != nil {
    return err
}

order := &Order{
    UserID: userID,
    ShippingAddressID: defaultAddress.ID,
    RecipientName: defaultAddress.RecipientName,
    RecipientPhone: defaultAddress.PhoneNumber,
    ShippingAddress: defaultAddress.GetFullAddress(),
}
```

## Cấu trúc thư mục

```
address/
├── entities/
│   ├── address.go          # Domain entity
│   └── errors.go           # Error definitions
├── api/
│   └── address_dto.go      # Request/Response DTOs
├── repositories/
│   ├── models.go           # Database model
│   ├── mapper.go           # Entity <-> Model mapper
│   └── address_gorm.go     # GORM implementation
├── services/
│   ├── ports.go            # Repository interface
│   └── address_service.go  # Business logic
├── controllers/
│   └── address_controller.go # HTTP handlers
├── module_routes.go        # Route registration
├── migrate.go              # Database migration
└── README.md               # Documentation
```

