// lib/core/config/flavor_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Map<String, String> envVars;

  FlavorConfig._(this.flavor, this.name, this.envVars);

  static FlavorConfig? _instance;

  static Future<void> init({
    required Flavor flavor,
    required String envFile,
  }) async {
    await dotenv.load(fileName: envFile);
    _instance = FlavorConfig._(
      flavor,
      flavor.toString().split('.').last.toUpperCase(),
      Map.from(dotenv.env),
    );
  }

  static FlavorConfig get instance {
    if (_instance == null) throw Exception('FlavorConfig chưa được khởi tạo!');
    return _instance!;
  }

  static bool get isProd => instance.flavor == Flavor.prod;
  static bool get isDev => instance.flavor == Flavor.dev;
}