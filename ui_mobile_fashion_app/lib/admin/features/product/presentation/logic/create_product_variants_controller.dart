import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class CreateProductVariantsController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createProductVariants({
    required int productId,
    required List<Map<String, dynamic>> uiColors,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dioClient = GetIt.I<dio.Dio>();

      List<Map<String, dynamic>> apiColors = [];
      List<Map<String, dynamic>> apiVariants = [];
      Map<String, List<XFile>> imageFilesMap = {};

      for (int i = 0; i < uiColors.length; i++) {
        final colorData = uiColors[i];
        final hex = colorData['hex'];
        final images = colorData['images'] as List<XFile>;
        final stocks = colorData['stocks'] as Map<String, int>;

        final imageKey = "color_${i}_images";

        apiColors.add({
          "hex": hex,
          "image_keys": [imageKey]
        });

        imageFilesMap[imageKey] = images;

        stocks.forEach((sizeCode, stockQty) {
          apiVariants.add({
            "color_hex": hex,
            "size_code": sizeCode,
            "stock": stockQty
          });
        });
      }

      final payloadObj = {
        "colors": apiColors,
        "variants": apiVariants,
      };

      final formData = dio.FormData.fromMap({
        'payload': jsonEncode(payloadObj),
      });

      // --- [FIX QUAN TRỌNG] Dùng fromBytes để chạy được trên Web ---
      for (var entry in imageFilesMap.entries) {
        String key = entry.key;
        List<XFile> files = entry.value;

        for (var file in files) {
          // Đọc bytes thay vì dùng path hệ thống
          final bytes = await file.readAsBytes();
          formData.files.add(MapEntry(
            key,
            dio.MultipartFile.fromBytes(bytes, filename: file.name),
          ));
        }
      }
      // -------------------------------------------------------------

      final response = await dioClient.post(
        '/admin/products/$productId/variants',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Lỗi server: ${response.statusCode}';
      }
    } on dio.DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối';
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}