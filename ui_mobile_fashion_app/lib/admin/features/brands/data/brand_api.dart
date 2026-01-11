import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'models/brand_model.dart';

class BrandApi {
  static final Dio _dio = getIt<Dio>();
  static const String _endpoint = '/brands';

  static Future<BrandListResponse> getBrands({int limit = 20}) async {
    try {
      final response = await _dio.get(
        _endpoint,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['code'] == 'OK') {
        return BrandListResponse.fromJson(response.data);
      }
      throw Exception('Lấy danh sách nhãn hàng thất bại');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối API');
    }
  }
}