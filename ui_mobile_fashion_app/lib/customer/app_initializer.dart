// lib/customer/app_initializer.dart
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import '../core/config/flavor_config.dart';

class AppInitializer {
  static Future<void> init({
    required Flavor flavor,
    String envFile = '.env.dev',
  }) async {
    // 1. Khởi tạo Flavor + .env.dev
    await FlavorConfig.init(flavor: flavor, envFile: envFile);

    // 2. Khởi tạo DI
    await setupDependencies();

    // 3. Khởi tạo API
    await ApiConfig.init();
  }
}