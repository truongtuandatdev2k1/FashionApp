// lib/customer/models/product_data.dart
class ProductData {
  final int id;
  final String imageUrl;
  final String name;
  final int price; // vẫn giữ int (vì backend trả về số nguyên)
  final int discountPct;
  final double priceAfter; // ĐỔI QUA DOUBLE (API trả về có .96)

  const ProductData({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.discountPct,
    required this.priceAfter, // double
  });

  factory ProductData.fromApi(Map<String, dynamic> json, String baseUrl) {
    return ProductData(
      id: json['id'] as int,
      imageUrl: baseUrl + json['image_url'],
      name: json['name'] as String,
      price: json['price'] as int,
      discountPct: (json['discount_pct'] ?? 0) as int,
      priceAfter:
          (json['priceAfter'] as num).toDouble(), // Ép an toàn num → double
    );
  }
}
