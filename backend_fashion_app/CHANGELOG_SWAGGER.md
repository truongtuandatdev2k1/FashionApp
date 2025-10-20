# Swagger API Documentation Update

## Thay đổi

### Trước đây
- Các API Category và Style **KHÔNG có** swagger annotations
- Swagger UI không hiển thị đầy đủ các endpoints

### Sau khi cập nhật
Đã thêm đầy đủ swagger annotations cho **TẤT CẢ** các API trong module Catalog:

#### ✅ Category APIs (JSON format)
- `POST /categories` - Create Category (Shop only)
  - `@Accept json`
  - `@Param body body api.CreateCategoryRequest`
  
- `GET /categories` - List Categories
  - Không cần Accept (GET request)
  
- `GET /categories/{id}` - Get Category by ID
  - `@Param id path int`
  
- `PUT /categories/{id}` - Update Category (Shop only)
  - `@Accept json`
  - `@Param body body api.UpdateCategoryRequest`
  
- `DELETE /categories/{id}` - Delete Category (Shop only)
  - Không cần Accept (DELETE request)

#### ✅ Style APIs (JSON format)
- `POST /styles` - Create Style (Shop only)
  - `@Accept json`
  - `@Param body body api.CreateStyleRequest`
  
- `GET /styles` - List Styles
  - Không cần Accept (GET request)
  
- `GET /styles/{id}` - Get Style by ID
  - `@Param id path int`
  
- `PUT /styles/{id}` - Update Style (Shop only)
  - `@Accept json`
  - `@Param body body api.UpdateStyleRequest`
  
- `DELETE /styles/{id}` - Delete Style (Shop only)
  - Không cần Accept (DELETE request)

#### ✅ Product APIs (Multipart format - GIỮ NGUYÊN)
- `POST /products` - Create Product (Shop only)
  - `@Accept multipart/form-data` ✅ (cần upload ảnh)
  - Các params: name, category_ids, style_ids, price, discount_pct, color, age_range, description
  - Files: background_image (required), other_images (optional, multiple)
  
- `GET /products` - List Products
  - Không cần Accept (GET request)
  
- `GET /products/{id}` - Get Product by ID
  - `@Param id path int`
  
- `PUT /products/{id}` - Update Product (Shop only)
  - `@Accept multipart/form-data` ✅ (có thể upload ảnh mới)
  - Các params tương tự Create (nhưng optional)
  
- `DELETE /products/{id}` - Delete Product (Shop only)
  - Không cần Accept (DELETE request)

## Kết quả

### Đồng bộ với các module khác
- ✅ Module **Auth**: Tất cả APIs dùng `@Accept json`
- ✅ Module **Profile**: Tất cả APIs dùng `@Accept json`
- ✅ Module **Catalog**: 
  - Category & Style APIs: `@Accept json` (đồng bộ)
  - Product Create/Update: `@Accept multipart/form-data` (bắt buộc vì upload file)

### Swagger UI
- Tất cả endpoints hiện đã xuất hiện trong Swagger UI
- Category & Style APIs: Có input box JSON để test
- Product Create/Update APIs: Có form upload file
- Dễ dàng test API trực tiếp từ Swagger UI tại: `http://localhost:4003/swagger/index.html`

## Cách test

1. Truy cập Swagger UI: `http://localhost:4003/swagger/index.html`
2. Test Category/Style APIs:
   - Click vào endpoint
   - Click "Try it out"
   - Nhập JSON vào body
   - Click "Execute"
3. Test Product APIs:
   - Click vào endpoint
   - Click "Try it out"
   - Điền form và upload file
   - Click "Execute"

## Files đã thay đổi

1. `internal/modules/catalog/controllers/catalog_controller.go`
   - Thêm swagger annotations cho tất cả handlers
   
2. `internal/common/httpx/docs/` (auto-generated)
   - `docs.go`
   - `swagger.json`
   - `swagger.yaml`

