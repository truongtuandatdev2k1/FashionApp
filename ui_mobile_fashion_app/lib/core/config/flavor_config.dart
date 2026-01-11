// lib/core/config/flavor_config.dart

enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String name;

  FlavorConfig._(this.flavor, this.name);

  static FlavorConfig? _instance;

  // Loại bỏ tham số envFile và logic dotenv.load
  static Future<void> init({required Flavor flavor}) async {
    _instance = FlavorConfig._(
      flavor,
      flavor.toString().split('.').last.toUpperCase(),
    );
  }

  static FlavorConfig get instance {
    if (_instance == null) throw Exception('FlavorConfig chưa được khởi tạo!');
    return _instance!;
  }

  static bool get isProd => instance.flavor == Flavor.prod;
  static bool get isDev => instance.flavor == Flavor.dev;
}
