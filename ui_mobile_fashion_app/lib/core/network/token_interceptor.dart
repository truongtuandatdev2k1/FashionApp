// lib/core/network/token_interceptor.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final accessToken = await TokenManager.getAccessToken(); // ← DÙNG STATIC
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: Xử lý refresh token nếu cần
    handler.next(err);
  }
}