// lib/customer/logic/saved/remove_wishlist_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class RemoveWishlistApi {
  static final _dio = getIt<Dio>();

  static Future<void> removeFromWishlist(int productId) async {
    try {
      final response = await _dio.delete('/wishlist/items/$productId');
      if (response.data['code'] != 'OK') {
        throw Exception(
          response.data['message'] ?? 'Xóa khỏi yêu thích thất bại',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng');
    }
  }
}