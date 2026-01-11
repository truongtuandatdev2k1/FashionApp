class Brand {
  final int id;
  final String name;
  final String logoUrl;
  final int counts;

  Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.counts,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String,
      counts: json['counts'] ?? 0,
    );
  }
}

class BrandListResponse {
  final List<Brand> brands;
  final int total;

  BrandListResponse({required this.brands, required this.total});

  factory BrandListResponse.fromJson(Map<String, dynamic> json) {
    final dataWrap = json['data'] as Map<String, dynamic>;
    final list = dataWrap['data'] as List;
    final meta = dataWrap['meta'] as Map<String, dynamic>;

    return BrandListResponse(
      brands: list.map((e) => Brand.fromJson(e)).toList(),
      total: meta['total'] as int,
    );
  }
}