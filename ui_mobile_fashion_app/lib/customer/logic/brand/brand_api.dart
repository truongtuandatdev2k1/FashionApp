// lib/customer/logic/brand/brand_api.dart

import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/api_client.dart';
import 'package:ui_mobile_fashion_app/customer/models/brand_model.dart';

class BrandApi {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<BrandModel>> getBrands({int limit = 100}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/brands',
      queryParameters: {'limit': limit},
    );

    final data = response.data!;
    final list = data['data']['data'] as List<dynamic>;
    return list.map((e) => BrandModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}