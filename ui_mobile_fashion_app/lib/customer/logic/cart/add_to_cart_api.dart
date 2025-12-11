// lib/customer/logic/cart/add_to_cart_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class AddToCartApi {
  static final _dio = getIt<Dio>();

  /// Thêm sản phẩm vào giỏ hàng
  /// productVariantId: ID biến thể (từ size + color)
  /// quantity: Số lượng
  static Future<void> addToCart(int productVariantId, int quantity) async {
    try {
      final response = await _dio.post(
        '/cart/items',
        data: {'product_variant_id': productVariantId, 'quantity': quantity},
      );

      if (response.data['code'] != 'CREATED') {
        throw Exception(
          response.data['message'] ?? 'Thêm vào giỏ hàng thất bại',
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Lỗi kết nối khi thêm sản phẩm';
      throw Exception(msg);
    } catch (e) {
      rethrow;
    }
  }
}
