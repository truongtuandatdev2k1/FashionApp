// lib/customer/models/product_detail_model.dart
class ProductDetailModel {
  final int id;
  final String name;
  final int price;
  final int priceAfter;
  final int discountPct;
  final String description;
  final String imageUrl; // ảnh chính
  final Brand brand;
  final List<Variant> variants;
  final List<String> sizes;
  final List<ColorInfo> colors;
  final int totalStock;
  final int soldCount;
  final double ratingAvg;

  ProductDetailModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceAfter,
    required this.discountPct,
    required this.description,
    required this.imageUrl,
    required this.brand,
    required this.variants,
    required this.sizes,
    required this.colors,
    required this.totalStock,
    required this.soldCount,
    required this.ratingAvg,
  });

  factory ProductDetailModel.fromJson(
    Map<String, dynamic> json,
    String baseUrl,
  ) {
    final data = json['data'];
    final brand = Brand.fromJson(data['brand'], baseUrl);

    final variants =
        (data['variants'] as List)
            .map((v) => Variant.fromJson(v, baseUrl))
            .toList();

    // Lấy tất cả ảnh từ các variant (không trùng)
    final Set<String> allImageUrls = {};
    for (var v in variants) {
      for (var img in v.images) {
        allImageUrls.add(img);
      }
    }
    // Nếu không có ảnh variant thì dùng ảnh chính
    if (allImageUrls.isEmpty) {
      allImageUrls.add(baseUrl + data['image_url']);
    }

    return ProductDetailModel(
      id: data['id'],
      name: data['name'],
      price: data['price'],
      priceAfter: data['priceAfter'],
      discountPct: data['discount_pct'] ?? 0,
      description: data['description'],
      imageUrl: baseUrl + data['image_url'],
      brand: brand,
      variants: variants,
      sizes: List<String>.from(data['sizes'] ?? []),
      colors:
          (data['colors'] as List).map((c) => ColorInfo.fromJson(c)).toList(),
      totalStock: data['total_stock'] ?? 0,
      soldCount: data['sold_count'] ?? 0,
      ratingAvg: (data['rating_avg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Brand {
  final String name;
  final String logoUrl;
  Brand({required this.name, required this.logoUrl});
  factory Brand.fromJson(Map<String, dynamic> json, String baseUrl) {
    return Brand(
      name: json['name'] ?? '',
      logoUrl: baseUrl + (json['logo_url'] ?? ''),
    );
  }
}

class Variant {
  final List<String> images;
  Variant(this.images);
  factory Variant.fromJson(Map<String, dynamic> json, String baseUrl) {
    final imgs =
        (json['images'] as List).map((i) => baseUrl + i['url']).toList();
    return Variant(imgs);
  }
}

class ColorInfo {
  final String name;
  final String hex;
  ColorInfo({required this.name, required this.hex});
  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return ColorInfo(name: json['color_name'], hex: json['color_hex']);
  }
}
