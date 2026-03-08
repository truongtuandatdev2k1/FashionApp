// lib/customer/logic/product/product_recommendations_api.dart

import 'package:ui_mobile_fashion_app/core/config/app_config.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';

class RecommendedProduct {
  final int id;
  final String name;
  final int price;
  final int discountPct;
  final double priceAfter;
  final String imageUrl;

  const RecommendedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPct,
    required this.priceAfter,
    required this.imageUrl,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      discountPct: json['discount_pct'] as int? ?? 0,
      priceAfter: (json['priceAfter'] as num?)?.toDouble() ?? 0.0,
      imageUrl: AppConfig.imageBaseUrl + (json['image_url'] as String? ?? ''),
    );
  }
}

class ProductRecommendationsApi {
  static Future<List<RecommendedProduct>> getRecommendations(
      int productId, {
        int limit = 10,
      }) async {
    final response = await ApiConfig.dio.get<Map<String, dynamic>>(
      '/products/$productId/recommendations',
      queryParameters: {'limit': limit},
    );

    final data = response.data;
    if (data == null || data['code'] != 'OK') return [];

    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((item) => RecommendedProduct.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}