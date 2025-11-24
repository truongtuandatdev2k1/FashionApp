// lib/core/utils/image_url_helper.dart
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';

class ImageUrlHelper {
  static String build(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path; // Đã là full URL
    return '${AppConfig.imageBaseUrl}$path';
  }
}