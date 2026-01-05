// lib/admin/features/product/domain/entities/product_entity.dart

class ProductEntity {
  final int id;
  final String name;
  final int price; // Giá gốc (int từ API)
  final int discountPct; // Phần trăm giảm giá
  final double priceAfter; // Giá sau giảm (có thể có thập phân)
  final String imageUrl; // Đã đầy đủ http://...

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPct,
    required this.priceAfter,
    required this.imageUrl,
  });

  // Format tiền tệ Việt Nam
  String get formattedPrice {
    return _formatCurrency(price.toDouble());
  }

  String get formattedPriceAfter {
    return _formatCurrency(priceAfter);
  }

  String _formatCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')} ₫';
  }

  // Factory từ JSON API /products/list
  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    final baseUrl = 'http://160.191.244.37:4003';
    final double originalPrice = (json['price'] ?? 0).toDouble();
    final int discount = json['discount_pct'] ?? 0;
    final double discountedPrice =
        (json['priceAfter'] ?? originalPrice).toDouble();

    return ProductEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Không có tên',
      price: originalPrice.toInt(),
      discountPct: discount,
      priceAfter: discountedPrice,
      imageUrl: baseUrl + (json['image_url'] as String? ?? ''),
    );
  }
}
