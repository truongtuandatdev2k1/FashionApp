// lib/customer/logic/address/address_service.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';

class AddressService {
  static final _dio = ApiConfig.dio;

  // Lấy danh sách
  static Future<List<Address>> getAddresses() async {
    try {
      final res = await _dio.get('/addresses');
      if (res.data['code'] == 'OK') {
        return (res.data['data'] as List)
            .map((e) => Address.fromJson(e))
            .toList();
      }
    } on DioException catch (_) {}
    return [];
  }

  // Thêm mới
  static Future<Address?> createAddress({
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String addressLine1,
    String? addressLine2,
    required String addressType,
  }) async {
    try {
      final body = {
        "recipient_name": recipientName,
        "phone_number": phoneNumber,
        "city": city,
        "district": district,
        "ward": ward,
        "address_line1": addressLine1,
        if (addressLine2?.isNotEmpty == true) "address_line2": addressLine2,
        "address_type": addressType,
      };

      final res = await _dio.post('/addresses', data: body);
      if (res.data['code'] == 'CREATED') {
        return Address.fromJson(res.data['data']);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
    return null;
  }

  // Cập nhật
  static Future<Address?> updateAddress({
    required int id,
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String addressLine1,
    String? addressLine2,
    required String addressType,
  }) async {
    try {
      final body = {
        "recipient_name": recipientName,
        "phone_number": phoneNumber,
        "city": city,
        "district": district,
        "ward": ward,
        "address_line1": addressLine1,
        if (addressLine2?.isNotEmpty == true) "address_line2": addressLine2,
        "address_type": addressType,
      };

      final res = await _dio.put('/addresses/$id', data: body);
      if (res.data['code'] == 'OK') {
        return Address.fromJson(res.data['data']);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
    return null;
  }

  // Đặt làm mặc định
  static Future<bool> setDefaultAddress(int addressId) async {
    try {
      final res = await _dio.patch('/addresses/$addressId/set-default');
      return res.data['code'] == 'OK';
    } on DioException {
      return false;
    }
  }

  // Xóa
  static Future<bool> deleteAddress(int addressId) async {
    try {
      final res = await _dio.delete('/addresses/$addressId');
      return res.data['code'] == 'OK';
    } on DioException {
      return false;
    }
  }

  static String _handleError(DioException e) {
    return e.response?.data?['message']?.toString() ?? "Có lỗi xảy ra";
  }
}
