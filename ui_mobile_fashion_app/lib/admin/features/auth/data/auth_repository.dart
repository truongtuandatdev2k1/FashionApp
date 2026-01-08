// lib/admin/features/auth/data/auth_repository.dart
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/api_client.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';
import 'package:ui_mobile_fashion_app/core/network/user_manager.dart';

class AdminAuthRepository {
  Future<bool> login({
    required String credential,
    required String password,
  }) async {
    final apiClient = getIt<ApiClient>(); // ← Lấy tại chỗ, khi cần

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {"credential": credential, "password": password},
      );

      final data = response.data?['data'];
      if (response.data?['code'] != 'OK' || data == null) {
        throw Exception('Đăng nhập thất bại');
      }

      final String token = data['token'];
      final String refreshToken = data['refreshToken'];
      final Map<String, dynamic> user = data['user'];

      if (user['role'] != 'shop') {
        throw Exception('Tài khoản không có quyền truy cập khu vực quản trị');
      }

      await TokenManager.saveTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      await UserManager.saveUser(
        id: user['id'],
        role: user['role'],
        name: credential,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
