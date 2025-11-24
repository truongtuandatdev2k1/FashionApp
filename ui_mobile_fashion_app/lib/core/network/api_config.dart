// lib/core/network/api_config.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';

class ApiConfig {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl, // Dùng từ .env.dev
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Future<void> init() async {
    await dotenv.load(fileName: ".env.dev"); // Load .env.dev

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
}