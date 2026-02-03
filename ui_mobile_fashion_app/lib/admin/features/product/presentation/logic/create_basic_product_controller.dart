// lib/admin/features/product/presentation/logic/create_basic_product_controller.dart

import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // ← THÊM DÒNG NÀY
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';

class CreateBasicProductController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  int? _createdProductId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get createdProductId => _createdProductId;

  Future<bool> createBasicProduct({
    required String name,
    required int price,
    required int discountPct,
    required int brandId,
    required int categoryId,
    required List<int> styleIds,
    required bool isHotTrend,
    required String ageRange,
    required String description,
    required Uint8List imageBytes,
    required String imageFileName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _createdProductId = null;
    notifyListeners();

    try {
      final dioClient = GetIt.I<dio.Dio>(); // ← Lấy Dio instance từ getIt

      final formData = dio.FormData.fromMap({
        'name': name,
        'price': price.toString(),
        'discount_pct': discountPct.toString(),
        'brand_id': brandId.toString(),
        'category_ids': categoryId.toString(),
        'style_ids': styleIds.join(','),
        'is_hot_trend': isHotTrend.toString(),
        'age_range': ageRange,
        'description': description,
        'img_url': dio.MultipartFile.fromBytes(
          imageBytes,
          filename: imageFileName,
        ),
      });

      final response = await dioClient.post(
        '/admin/products/basic',
        data: formData,
      );

      if (response.statusCode == 201) {
        final jsonData = response.data;
        if (jsonData['code'] == 'CREATED') {
          _createdProductId = jsonData['data']['id'] as int;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Tạo sản phẩm thất bại: ${jsonData['message'] ?? 'Không rõ lỗi'}';
        }
      } else {
        _errorMessage = 'Lỗi server: ${response.statusCode} - ${response.data}';
      }
    } on dio.DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối';
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      }
    } catch (e) {
      _errorMessage = 'Không thể gửi yêu cầu: $e';
    }

    notifyListeners();
    return false;
  }
}