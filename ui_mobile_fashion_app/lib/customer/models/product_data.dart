// lib/customer/models/product_data.dart
class ProductData {
  final String imageUrl;
  final String name;
  final int price;
  final int discountPct;
  final int priceAfter;

  const ProductData({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.discountPct,
    required this.priceAfter,
  });

  factory ProductData.fromApi(Map<String, dynamic> json, String baseUrl) {
    return ProductData(
      imageUrl: baseUrl + json['image_url'],
      name: json['name'],
      price: json['price'],
      discountPct: json['discount_pct'] ?? 0,
      priceAfter: json['priceAfter'],
    );
  }
}