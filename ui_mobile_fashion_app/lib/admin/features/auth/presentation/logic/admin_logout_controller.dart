// lib/admin/features/auth/presentation/logic/admin_logout_controller.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';
import 'package:ui_mobile_fashion_app/core/network/user_manager.dart';
import 'package:dio/dio.dart';

class AdminLogoutController {
  static final _dio = getIt<Dio>();

  /// Đăng xuất admin - gọi API và xóa local data
  static Future<void> logout(BuildContext context) async {
    try {
      developer.log('🔥 Bắt đầu đăng xuất admin...', name: 'AdminLogout');

      // Gọi API logout
      final response = await _dio.post('/auth/logout');

      if (response.data['code'] == 'OK') {
        developer.log('✅ API logout thành công', name: 'AdminLogout');
      } else {
        developer.log(
          '⚠️ API logout trả về code khác OK: ${response.data['code']}',
          name: 'AdminLogout',
        );
      }
    } on DioException catch (e) {
      // Nếu API lỗi (401, network...), vẫn xóa local và redirect
      developer.log(
        '⚠️ API logout lỗi (vẫn tiếp tục xóa local): ${e.message}',
        name: 'AdminLogout',
      );
    } catch (e) {
      developer.log(
        '⚠️ Lỗi không xác định khi logout: $e',
        name: 'AdminLogout',
      );
    } finally {
      // Dù API có lỗi hay không, vẫn xóa token và user info local
      await TokenManager.clearTokens();
      await UserManager.clearUser();

      developer.log('✅ Đã xóa token và user info local', name: 'AdminLogout');

      // Redirect về login
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  /// Hiển thị dialog xác nhận logout
  static Future<void> showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await logout(context);
    }
  }
}