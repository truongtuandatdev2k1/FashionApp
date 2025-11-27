// lib/customer/models/product_detail_model.dart

class ProductDetailModel {
  final int id;
  final String name;
  final int price; // Giá gốc (nguyên)
  final double priceAfter; // Giá sau giảm (có thể có .96, .99 → phải là double)
  final int discountPct;
  final String description;
  final String imageUrl;
  final Brand brand;
  final List<Variant> variants;
  final List<String> sizes;
  final List<ColorInfo> colors;
  final int totalStock;
  final int soldCount;
  final double ratingAvg;

  const ProductDetailModel({
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

  // Gom tất cả ảnh từ các variant + ảnh chính
  List<String> get allImages {
    final Set<String> images = {};
    for (final variant in variants) {
      images.addAll(variant.images);
    }
    if (images.isEmpty && imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }
    return images.toList();
  }

  factory ProductDetailModel.fromJson(
    Map<String, dynamic> json,
    String baseUrl,
  ) {
    final data = json['data'] as Map<String, dynamic>;

    // Brand
    final brandJson = data['brand'] as Map<String, dynamic>? ?? {};
    final brand = Brand.fromJson(brandJson, baseUrl);

    // Variants
    final variantList = data['variants'] as List<dynamic>? ?? [];
    final variants =
        variantList
            .map((v) => Variant.fromJson(v as Map<String, dynamic>, baseUrl))
            .toList();

    // Colors
    final colorList = data['colors'] as List<dynamic>? ?? [];
    final colors =
        colorList
            .map((c) => ColorInfo.fromJson(c as Map<String, dynamic>))
            .toList();

    // Sizes
    final sizeList = data['sizes'] as List<dynamic>? ?? [];
    final sizes = sizeList.cast<String>();

    return ProductDetailModel(
      id: data['id'] as int,
      name: data['name'] as String? ?? 'Không có tên',
      price: data['price'] as int,
      priceAfter:
          (data['priceAfter'] as num)
              .toDouble(), // ← Quan trọng: ép num → double
      discountPct: (data['discount_pct'] ?? 0) as int,
      description: data['description'] as String? ?? 'Không có mô tả',
      imageUrl: baseUrl + (data['image_url'] as String? ?? ''),
      brand: brand,
      variants: variants,
      sizes: sizes,
      colors: colors,
      totalStock: (data['total_stock'] ?? 0) as int,
      soldCount: (data['sold_count'] ?? 0) as int,
      ratingAvg: (data['rating_avg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ==================== Brand ====================
class Brand {
  final String name;
  final String logoUrl;

  const Brand({required this.name, required this.logoUrl});

  factory Brand.fromJson(Map<String, dynamic> json, String baseUrl) {
    return Brand(
      name: json['name'] as String? ?? 'Không rõ thương hiệu',
      logoUrl: json['logo_url'] != null ? baseUrl + json['logo_url'] : '',
    );
  }
}

// ==================== Variant ====================
class Variant {
  final int id;
  final double price; // ← Cũng nên là double cho an toàn
  final int stock;
  final String sku;
  final String colorName;
  final String colorHex;
  final String sizeCode;
  final List<String> images;

  const Variant({
    required this.id,
    required this.price,
    required this.stock,
    required this.sku,
    required this.colorName,
    required this.colorHex,
    required this.sizeCode,
    required this.images,
  });

  factory Variant.fromJson(Map<String, dynamic> json, String baseUrl) {
    final imageList = json['images'] as List<dynamic>? ?? [];
    final images =
        imageList.map((img) => baseUrl + (img['url'] as String)).toList();

    return Variant(
      id: json['id'] as int,
      price: (json['price'] as num).toDouble(), // ← ép an toàn
      stock: json['stock'] as int? ?? 0,
      sku: json['sku'] as String? ?? '',
      colorName: json['color_name'] as String? ?? 'Không rõ màu',
      colorHex: json['color_hex'] as String? ?? '#000000',
      sizeCode: json['size_code'] as String? ?? '',
      images: images,
    );
  }
}

// ==================== ColorInfo ====================
class ColorInfo {
  final String name;
  final String hex;

  const ColorInfo({required this.name, required this.hex});

  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return ColorInfo(
      name: json['color_name'] as String? ?? 'Không rõ',
      hex: json['color_hex'] as String? ?? '#000000',
    );
  }
}
