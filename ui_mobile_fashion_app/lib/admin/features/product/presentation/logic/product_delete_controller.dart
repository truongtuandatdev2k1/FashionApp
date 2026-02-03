import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProductDeleteController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dioClient = GetIt.I<Dio>();

      final response = await dioClient.delete('/products/$productId');

      if (response.statusCode == 200) {
        final data = response.data;
        // Kiểm tra an toàn xem data có phải Map không
        if (data is Map && data['code'] == 'OK') {
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = (data is Map ? data['message'] : data.toString()) ?? 'Lỗi xóa sản phẩm';
        }
      } else {
        _errorMessage = 'Lỗi server: ${response.statusCode}';
      }
    } on DioException catch (e) {
      // [FIX LỖI] Kiểm tra kỹ kiểu dữ liệu trả về của error
      final data = e.response?.data;
      if (data != null && data is Map) {
        // Nếu Server trả về JSON lỗi
        _errorMessage = data['message'] ?? e.message ?? 'Lỗi kết nối';
      } else if (data != null && data is String) {
        // Nếu Server trả về String (ví dụ: "Unauthorized")
        _errorMessage = data;
      } else {
        // Fallback
        _errorMessage = e.message ?? 'Lỗi kết nối';
      }
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}