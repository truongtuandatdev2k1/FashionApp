// lib/core/network/api_config.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';

class ApiConfig {
  // Thay 'final' bằng 'late', không khởi tạo ngay tại đây
  static late Dio dio;

  static Future<void> init() async {
    // Chỉ khởi tạo Dio sau khi dotenv đã load xong ở main()
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
