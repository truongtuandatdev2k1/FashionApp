// lib/customer/logic/profile/update_profile_api.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';

class UpdateProfileApi {
  static final _dio = ApiConfig.dio;

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String age,
    required String address,
    required String gender,
    File? avatarFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'full_name': fullName,
        'age': age,
        'address': address,
        'gender': gender,
      });

      if (avatarFile != null) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      final response = await _dio.put('/profiles/me', data: formData);

      if (response.data['code'] == 'OK') {
        // Trả về data mới nhất nếu API có trả về, không thì map rỗng
        return response.data['data'] ?? {};
      } else {
        throw Exception(response.data['message'] ?? 'Cập nhật hồ sơ thất bại');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Lỗi kết nối server';
      throw Exception(msg);
    }
  }
}