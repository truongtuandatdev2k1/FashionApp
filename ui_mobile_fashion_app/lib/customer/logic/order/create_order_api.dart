// lib/customer/logic/order/create_order_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/order/order_request.dart';

class CreateOrderApi {
  static final Dio _dio = ApiConfig.dio;
  static const String _orderEndpoint = '/orders';

  /// Tạo đơn hàng mới.
  /// Trả về ID đơn hàng (String) nếu thành công, ngược lại ném ra Exception.
  // Thay đổi kiểu trả về thành Future<String> vì 'id' là String (UUID)
  static Future<String> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post(_orderEndpoint, data: request.toJson());

      // Response API của bạn không có code và data, nó trả về trực tiếp đối tượng.
      // Kiểm tra xem trường 'id' có tồn tại không.
      if (response.data != null && response.data['id'] is String) {
        // Trích xuất ID (dạng String/UUID)
        final String orderId = response.data['id'];

        // Log.i('Order created successfully with ID: $orderId'); // Dùng Logger
        return orderId;
      }

      // Trường hợp request thành công nhưng dữ liệu trả về không đúng format
      throw Exception(
        'Đặt hàng thành công nhưng không nhận được ID đơn hàng hợp lệ.',
      );
    } on DioException catch (e) {
      // In lỗi chi tiết từ backend ra console để debug
      final errorMessage =
          e.response?.data?['message'] ??
          'Lỗi kết nối hoặc dữ liệu không hợp lệ.';
      // Log.e('CreateOrderApi error: $errorMessage'); // Dùng Logger
      throw Exception('Lỗi đặt hàng: $errorMessage');
    } catch (e) {
      // Log.e('CreateOrderApi unexpected error: $e'); // Dùng Logger
      throw Exception('Lỗi không xác định khi đặt hàng.');
    }
  }
}
