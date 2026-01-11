// lib/admin/features/order/data/admin_order_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';
import '../data/models/admin_order_model.dart';

class AdminOrderApi {
  static final Dio _dio = getIt<Dio>();
  static const String _endpoint = '/admin/orders';

  /// Lấy danh sách đơn hàng (admin)
  static Future<AdminOrderListResponse> getOrders({
    int limit = 20,
    int offset = 0,
    String? status, // Filter theo status nếu cần
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _dio.get(
        _endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['code'] == 'OK') {
        return AdminOrderListResponse.fromJson(response.data);
      }

      throw Exception('Tải danh sách đơn hàng không thành công.');
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi kết nối mạng.';
      throw Exception('Lỗi API: $errorMessage');
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải đơn hàng: $e');
    }
  }
}