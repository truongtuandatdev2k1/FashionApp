// lib/customer/logic/saved/add_wishlist_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class AddWishlistApi {
  static final _dio = getIt<Dio>();

  static Future<void> addToWishlist(int productId) async {
    try {
      final response = await _dio.post(
        '/wishlist/items',
        data: {'product_id': productId},
      );
      if (response.data['code'] != 'OK') {
        throw Exception(
          response.data['message'] ?? 'Thêm vào yêu thích thất bại',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng');
    }
  }
}