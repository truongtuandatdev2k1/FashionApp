// lib/customer/logic/profile/profile_api.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';

class ProfileApi {
  static final _dio = ApiConfig.dio;

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/profiles/me');

      if (response.data['code'] == 'OK') {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Lấy thông tin thất bại');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
    }
  }
}