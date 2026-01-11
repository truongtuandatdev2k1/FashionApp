// lib/customer/app_initializer.dart
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import '../core/config/flavor_config.dart';

class AppInitializer {
  static Future<void> init({required Flavor flavor}) async {
    // 1. Khởi tạo Flavor trực tiếp không dùng file env
    await FlavorConfig.init(flavor: flavor);

    // 2. Khởi tạo DI
    await setupDependencies();

    // 3. Khởi tạo API
    await ApiConfig.init();
  }
}
