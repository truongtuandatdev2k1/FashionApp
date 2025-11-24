// lib/core/di/locator.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_mobile_fashion_app/core/network/api_client.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';
import 'package:ui_mobile_fashion_app/core/network/token_interceptor.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Token Manager
  getIt.registerLazySingleton<TokenManager>(() => TokenManager());

  // Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = ApiConfig.dio;
    dio.interceptors.add(TokenInterceptor()); // ← DÙNG TRỰC TIẾP
    return dio;
  });

  // ApiClient
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
}