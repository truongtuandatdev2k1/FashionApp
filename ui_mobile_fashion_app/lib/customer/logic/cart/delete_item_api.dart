// lib/customer/logic/cart/delete_item_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class DeleteItemApi {
  static final _dio = getIt<Dio>();

  /// Xóa 1 sản phẩm khỏi giỏ hàng
  /// itemId: là id của cart item (ví dụ: 9, 8, 7 trong API)
  static Future<void> deleteCartItem(int itemId) async {
    try {
      final response = await _dio.delete('/cart/items/$itemId');

      if (response.data['code'] != 'OK') {
        throw Exception(response.data['message'] ?? 'Xóa sản phẩm thất bại');
      }
      // Thành công → không cần return gì
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Lỗi kết nối khi xóa sản phẩm';
      throw Exception(msg);
    } catch (e) {
      rethrow;
    }
  }
}
