# Order Module

Module quản lý đơn hàng trong hệ thống MyFashion.

## Tính năng

### Customer Features
- ✅ Tạo đơn hàng mới từ giỏ hàng
- ✅ Xem danh sách đơn hàng của mình
- ✅ Xem chi tiết đơn hàng
- ✅ Lọc đơn hàng theo trạng thái
- ✅ Hủy đơn hàng (khi ở trạng thái pending/confirmed)

### Shop Features
- ✅ Xem danh sách đơn hàng của shop
- ✅ Xác nhận đơn hàng
- ✅ Cập nhật trạng thái đơn hàng
- ✅ Hủy đơn hàng

## Order Status Flow

```
pending → confirmed → processing → shipping → delivered
   ↓          ↓           ↓
cancelled  cancelled  cancelled
```

## Payment Methods

- `cod` - Cash on Delivery (Thanh toán khi nhận hàng)
- `bank_transfer` - Chuyển khoản ngân hàng
- `e_wallet` - Ví điện tử

## Payment Status

- `pending` - Chờ thanh toán
- `paid` - Đã thanh toán
- `failed` - Thanh toán thất bại
- `refunded` - Đã hoàn tiền

## Database Schema

### orders table
- `id` (UUID) - Primary key
- `order_number` (string) - Mã đơn hàng (unique)
- `customer_id` (uint) - Foreign key to users
- `shop_id` (uint) - Foreign key to users
- Shipping information (name, phone, address, province, district, ward)
- Order totals (total_amount, shipping_fee, discount_amount, final_amount)
- Payment info (payment_method, payment_status)
- Status tracking (status, note, cancel_reason)
- Timestamps (created_at, updated_at, confirmed_at, shipped_at, delivered_at, cancelled_at)

### order_items table
- `id` (UUID) - Primary key
- `order_id` (UUID) - Foreign key to orders
- `product_id` (uint) - Foreign key to products
- Product snapshot (name, SKU, image, size, color)
- Pricing (quantity, price, subtotal)
- `created_at` - Timestamp

## API Endpoints

### Customer Endpoints
- `POST /api/v1/orders` - Tạo đơn hàng mới
- `GET /api/v1/orders` - Lấy danh sách đơn hàng (với filter status)
- `GET /api/v1/orders/{id}` - Xem chi tiết đơn hàng
- `POST /api/v1/orders/{id}/cancel` - Hủy đơn hàng

### Shop Endpoints (require shop role)
- `GET /api/v1/orders` - Lấy danh sách đơn hàng của shop
- `POST /api/v1/orders/{id}/confirm` - Xác nhận đơn hàng
- `PUT /api/v1/orders/{id}/status` - Cập nhật trạng thái đơn hàng
- `POST /api/v1/orders/{id}/cancel` - Hủy đơn hàng

## Business Rules

1. **Order Creation**
   - Phải có ít nhất 1 sản phẩm
   - Phải có đầy đủ thông tin giao hàng
   - Tự động tính tổng tiền

2. **Order Confirmation**
   - Chỉ shop mới có thể xác nhận
   - Chỉ có thể xác nhận đơn hàng ở trạng thái `pending`

3. **Status Update**
   - Chỉ shop mới có thể cập nhật
   - Phải tuân theo flow: pending → confirmed → processing → shipping → delivered
   - Không thể cập nhật đơn hàng đã cancelled/delivered

4. **Order Cancellation**
   - Customer chỉ có thể hủy khi ở trạng thái `pending` hoặc `confirmed`
   - Shop có thể hủy khi ở trạng thái `pending`, `confirmed`, `processing`
   - Phải có lý do hủy

5. **Payment**
   - Đơn hàng COD: payment_status = `pending` cho đến khi delivered
   - Đơn hàng chuyển khoản/ví: cần xác nhận thanh toán trước khi ship

## TODO / Future Enhancements

- [ ] Tích hợp với Cart service để tạo order từ giỏ hàng
- [ ] Tính phí ship tự động dựa trên địa chỉ
- [ ] Áp dụng mã giảm giá (voucher/coupon)
- [ ] Tracking đơn hàng với mã vận đơn
- [ ] Thông báo realtime khi đơn hàng thay đổi trạng thái
- [ ] Đánh giá sản phẩm sau khi nhận hàng
- [ ] Xuất hóa đơn PDF
- [ ] Báo cáo doanh thu cho shop

## Architecture

```
controllers/
  └── order_controller.go    # HTTP handlers

services/
  ├── order_service.go        # Business logic
  └── ports.go                # Service interfaces

repositories/
  ├── order_gorm.go           # Database access
  ├── models.go               # GORM models
  └── mapper.go               # Entity ↔ Model mapping

entities/
  ├── order.go                # Domain entities
  └── errors.go               # Domain errors

api/
  └── order_dto.go            # Request/Response DTOs
```

## Testing

Sử dụng Swagger UI để test: http://localhost:8080/swagger/index.html

1. Đăng nhập để lấy token
2. Click "Authorize" và nhập token
3. Test các endpoints Order

