// lib/customer/logic/order/get_orders_api.dart
import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/order/order_response.dart';

class GetOrdersApi {
  static final Dio _dio = ApiConfig.dio;
  static const String _orderEndpoint = '/orders';

  /// Lấy danh sách đơn hàng của khách hàng.
  static Future<OrderListResponse> getOrders({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        _orderEndpoint,
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200 && response.data['code'] == 'OK') {
        return OrderListResponse.fromJson(response.data);
      }

      throw Exception('Tải danh sách đơn hàng không thành công.');
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi kết nối mạng.';
      // Log.e('GetOrdersApi error: $errorMessage');
      throw Exception('Lỗi API: $errorMessage');
    } catch (e) {
      // Log.e('GetOrdersApi unexpected error: $e');
      throw Exception('Lỗi không xác định khi tải đơn hàng.');
    }
  }
}
