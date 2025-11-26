// lib/customer/logic/product/product_api.dart
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_data.dart';

class ProductApi {
  static final _dio = ApiConfig.dio;

  static Future<List<ProductData>> getList({
    required String filter,
    int limit = 10,
    int page = 1, // ĐÃ THÊM
  }) async {
    try {
      final response = await _dio.post(
        '/products/list',
        data: {
          'filter': filter,
          'limit': limit,
          'page': page, // ĐÃ THÊM
        },
      );

      if (response.data['code'] == 'OK') {
        final List items = response.data['data']['data'];
        final baseUrl = _dio.options.baseUrl.replaceAll('/api/v1', '');
        return items.map((json) => ProductData.fromApi(json, baseUrl)).toList();
      }
    } catch (e) {
      print('ProductApi error: $e');
    }
    return [];
  }
}
