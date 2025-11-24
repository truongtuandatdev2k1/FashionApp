// lib/core/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => '${dotenv.env['API_BASE_URL']}/api/${dotenv.env['API_VERSION']}';
  static String get imageBaseUrl => dotenv.env['API_BASE_URL']!;
}