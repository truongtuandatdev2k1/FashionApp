import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart'; // Thêm import này
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class AddBrandApi {
  static final Dio _dio = getIt<Dio>();
  static const String _endpoint = '/admin/brands';

  static Future<void> addBrand({
    required String name,
    required XFile logoFile, // Đổi từ File thành XFile
  }) async {
    try {
      // Đọc dữ liệu dưới dạng bytes để hỗ trợ cả Web và Mobile
      final bytes = await logoFile.readAsBytes();

      FormData formData = FormData.fromMap({
        "name": name,
        "logo": MultipartFile.fromBytes(
          bytes,
          filename: logoFile.name,
        ),
      });

      final response = await _dio.post(
        _endpoint,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw Exception('Thêm nhãn hàng thất bại');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Lỗi kết nối server';
      throw Exception(msg);
    }
  }
}