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
          if (brandId != null) "brand_id": brandId, // Thêm filter theo brand
        },
      );

      if (response.data?['code'] != 'OK') {
        throw Exception('Lỗi từ server');
      }

      final List<dynamic> items = response.data?['data']?['data'] ?? [];
      _products = items.map((json) => ProductEntity.fromJson(json)).toList();

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
    }
  }
}
