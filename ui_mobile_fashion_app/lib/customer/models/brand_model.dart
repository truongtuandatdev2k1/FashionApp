// lib/customer/models/brand_model.dart

class BrandModel {
  final int id;
  final String name;
  final String logoUrl;
  final int counts;

  const BrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.counts,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String,
      counts: json['counts'] as int,
    );
  }
}