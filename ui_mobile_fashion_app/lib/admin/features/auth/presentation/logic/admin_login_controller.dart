// lib/admin/features/auth/presentation/logic/admin_login_controller.dart
import 'dart:developer' as developer;
import 'package:ui_mobile_fashion_app/admin/features/auth/data/auth_repository.dart';

class AdminLoginController {
  final AdminAuthRepository _authRepository = AdminAuthRepository();

  Future<String?> login({
    required String credential,
    required String password,
  }) async {
    try {
      developer.log(
        '🔥 Bắt đầu đăng nhập admin: $credential',
        name: 'AdminLogin',
      );

      final success = await _authRepository.login(
        credential: credential,
        password: password,
      );

      if (success) {
        developer.log('✅ Đăng nhập admin THÀNH CÔNG!', name: 'AdminLogin');
        return null; // null nghĩa là không có lỗi
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ LỖI ĐĂNG NHẬP ADMIN: $e',
        name: 'AdminLogin',
        error: e,
        stackTrace: stackTrace,
      );

      // Xử lý thông báo lỗi thân thiện cho UI
      if (e.toString().contains(
            'Tài khoản không có quyền truy cập khu vực quản trị',
          ) ||
          e.toString().contains('shop')) {
        return 'Tài khoản không có quyền quản trị';
      } else if (e.toString().contains('Đăng nhập thất bại')) {
        return 'Email hoặc mật khẩu không đúng';
      } else if (e.toString().contains('timeout')) {
        return 'Kết nối timeout, vui lòng thử lại';
      } else if (e.toString().contains('404')) {
        return 'Không thể kết nối đến server';
      } else {
        return 'Đăng nhập thất bại, vui lòng thử lại';
      }
    }
    return 'Đăng nhập thất bại';
  }
}
