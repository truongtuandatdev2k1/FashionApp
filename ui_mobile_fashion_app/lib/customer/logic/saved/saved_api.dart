// lib/customer/logic/saved/saved_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class WishlistProduct {
  final int id;
  final String name;
  final double price;
  final int discountPct;
  final double priceAfter;
  final String imageUrl;
  final String status;

  WishlistProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPct,
    required this.priceAfter,
    required this.imageUrl,
    required this.status,
  });

  String get fullImageUrl => 'http://160.191.244.37:4003$imageUrl';

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    return WishlistProduct(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      discountPct: json['discount_pct'],
      priceAfter: (json['priceAfter'] as num).toDouble(),
      imageUrl: json['image_url'],
      status: json['status'],
    );
  }
}

class WishlistResponse {
  final List<WishlistProduct> items;

  WishlistResponse({required this.items});

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List;
    return WishlistResponse(
      items: list.map((e) => WishlistProduct.fromJson(e)).toList(),
    );
  }
}

class SavedApi {
  static final _dio = getIt<Dio>();

  /// Lấy danh sách sản phẩm yêu thích
  static Future<WishlistResponse> getWishlist({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/wishlist',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data['code'] == 'OK') {
        return WishlistResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Lấy danh sách yêu thích thất bại',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng');
    }
  }

  /// Thêm sản phẩm vào yêu thích
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

// TODO: Thêm removeFromWishlist sau này
}