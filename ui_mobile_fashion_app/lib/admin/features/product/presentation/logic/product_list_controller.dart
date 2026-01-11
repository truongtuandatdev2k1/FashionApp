// lib/admin/features/product/presentation/logic/product_list_controller.dart
import 'dart:developer' as developer;

import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/api_client.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/domain/entities/product_entity.dart';

class ProductListController {
  final ApiClient _apiClient = getIt<ApiClient>();

  List<ProductEntity> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<ProductEntity> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách sản phẩm, hỗ trợ lọc theo brandId (tùy chọn)
  Future<void> fetchProducts({int? brandId}) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/products/list',
        data: {
          "filter": "all",
          "limit": 50,
          "page": 1,
          if (brandId != null) "brand_id": brandId, // Lọc theo thương hiệu
        },
      );

      if (response.data?['code'] != 'OK') {
        throw Exception('Lỗi từ server: ${response.data?['message'] ?? 'Unknown error'}');
      }

      final List<dynamic> items = response.data?['data']?['data'] ?? [];
      _products = items.map((json) => ProductEntity.fromJson(json)).toList();

      developer.log('Fetched ${items.length} products (brandId: $brandId)');
    } catch (e, stackTrace) {
      _errorMessage = 'Không thể tải danh sách sản phẩm: $e';
      developer.log('Error fetching products', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  /// Có thể thêm phương thức refresh nếu cần
  Future<void> refresh({int? brandId}) => fetchProducts(brandId: brandId);

  /// Xóa dữ liệu hiện tại (dùng khi cần reset)
  void clear() {
    _products = [];
    _errorMessage = null;
  }
}