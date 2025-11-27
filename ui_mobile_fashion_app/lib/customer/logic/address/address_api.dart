// lib/customer/logic/address/address_api.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';

class AddressApi {
  static final Dio _dio = ApiConfig.dio;

  static Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses');
      if (response.data['code'] == 'OK') {
        final List data = response.data['data'];
        return data.map((json) => Address.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('AddressApi error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('AddressApi unexpected error: $e');
    }
    return [];
  }
}
