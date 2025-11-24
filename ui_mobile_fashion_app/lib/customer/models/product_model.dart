// // lib/customer/models/product_model.dart
// import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
//
// class ProductModel {
//   final int id;
//   final String name;
//   final double price;           // ĐÃ SỬA: int → double
//   final int discountPct;
//   final double priceAfter;      // ĐÃ SỬA: int → double
//   final String imageUrl;
//
//   ProductModel({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.discountPct,
//     required this.priceAfter,
//     required this.imageUrl,
//   });
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: json['id'],
//       name: json['name'],
//       price: (json['price'] as num).toDouble(),
//       discountPct: json['discount_pct'] ?? 0,
//       priceAfter: (json['price_after'] as num).toDouble(),
//       imageUrl: json['image_url'],
//     );
//   }
//
//   String get fullImageUrl {
//     final baseUrl = ApiConfig.dio.options.baseUrl.replaceAll('/api/v1', '');
//     return baseUrl + imageUrl;
//   }
// }