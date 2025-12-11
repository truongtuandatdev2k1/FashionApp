// lib/customer/logic/address/address_default_api.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';
// import 'package:ui_mobile_fashion_app/core/utils/logger.dart'; // Giả định bạn có Logger

class AddressDefaultApi {
  static final Dio _dio = ApiConfig.dio;
  static const String _defaultAddressEndpoint = '/addresses/default';

  /// Lấy địa chỉ mặc định của người dùng.
  /// Trả về đối tượng Address nếu thành công, ngược lại trả về null.
  static Future<Address?> getDefaultAddress() async {
    try {
      final response = await _dio.get(_defaultAddressEndpoint);

      if (response.data['code'] == 'OK' && response.data['data'] != null) {
        // Log.i('Default Address fetched: ${response.data['data']}'); // Sử dụng Logger nếu có
        return Address.fromJson(response.data['data']);
      }

      // Trường hợp không có địa chỉ mặc định, data có thể là null
      return null;
    } on DioException catch (e) {
      // Log.e('AddressDefaultApi error: ${e.response?.data ?? e.message}'); // Sử dụng Logger nếu có
      print('AddressDefaultApi error: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      // Log.e('AddressDefaultApi unexpected error: $e'); // Sử dụng Logger nếu có
      print('AddressDefaultApi unexpected error: $e');
      return null;
    }
  }
}
