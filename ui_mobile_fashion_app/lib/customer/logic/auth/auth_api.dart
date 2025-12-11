// lib/customer/logic/auth/auth_api.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';
import 'package:ui_mobile_fashion_app/core/network/user_manager.dart';
import 'package:go_router/go_router.dart'; // THÊM

class CustomerAuthApi {
  static final _dio = getIt<Dio>(); // hoặc ApiConfig.dio

  static Future<Map<String, dynamic>> login(
    String credential,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {"credential": credential, "password": password},
      );

      if (response.data['code'] == 'OK') {
        final data = response.data['data'];
        final token = data['token'] as String;
        final user = data['user'];

        await TokenManager.saveTokens(
          accessToken: token,
          refreshToken: token, // nếu không có refresh, tạm dùng access
        );

        await UserManager.saveUser(
          id: user['id'],
          role: user['role'],
          name: "Khách hàng #${user['id']}",
        );

        return data;
      } else {
        throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
    }
  }

  // === LOGOUT ===
  static Future<void> logout(BuildContext context) async {
    try {
      final response = await _dio.post('/auth/logout');

      if (response.data['code'] == 'OK') {
        // 1. Xóa token
        await TokenManager.clearTokens();

        // 2. Xóa user info
        await UserManager.clearUser();

        // 3. Chuyển về Login
        if (context.mounted) {
          context.go('/login');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Đăng xuất thất bại');
      }
    } on DioException {
      // Nếu API lỗi (ví dụ: 401, mạng), vẫn xóa local và về login
      await TokenManager.clearTokens();
      await UserManager.clearUser();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  // lib/customer/logic/auth/auth_api.dart

  static Future<void> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          "email": email,
          "phone_number": phone,
          "password": password,
          "confirmPassword": password,
        },
      );

      if (response.data['code'] != 'OK') {
        throw Exception(response.data['message'] ?? 'Đăng ký thất bại');
      }

      // Đăng ký thành công → tự động đăng nhập luôn
      final data = response.data['data'];
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String? ?? token;
      final user = data['user'];

      await TokenManager.saveTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );
      await UserManager.saveUser(
        id: user['id'],
        role: user['role'],
        name: "Khách hàng #${user['id']}",
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Lỗi kết nối server';
      throw Exception(msg);
    } catch (e) {
      rethrow;
    }
  }
}
