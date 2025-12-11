// lib/customer/logic/profile/update_profile_api.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class UpdateProfileApi {
  static final _dio = getIt<Dio>();

  /// Cập nhật thông tin cá nhân
  /// full_name: String
  /// age: String (API nhận text)
  /// address: String
  /// gender: cố định "nam"
  /// avatarFile: File? (có thể null nếu không chọn ảnh)
  static Future<void> updateProfile({
    required String fullName,
    required String age,
    required String address,
    File? avatarFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'full_name': fullName,
        'age': age,
        'address': address,
        'gender': 'nam', // Shop nam → cố định
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

      if (response.data['code'] != 'OK') {
        throw Exception(response.data['message'] ?? 'Cập nhật hồ sơ thất bại');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Lỗi kết nối server';
      throw Exception(msg);
    } catch (e) {
      rethrow;
    }
  }
}
