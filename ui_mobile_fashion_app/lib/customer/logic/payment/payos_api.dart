// lib/customer/logic/payment/payos_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';

/// Model cho response tạo payment link
class PayOSCreateResponse {
  final String checkoutUrl;
  final int orderCode;
  final String qrCode;

  PayOSCreateResponse({
    required this.checkoutUrl,
    required this.orderCode,
    required this.qrCode,
  });

  factory PayOSCreateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PayOSCreateResponse(
      checkoutUrl: data['checkout_url'] ?? data['checkoutUrl'] ?? '',
      orderCode: data['order_code'] ?? data['orderCode'] ?? 0,
      qrCode: data['qr_code'] ?? data['qrCode'] ?? '',
    );
  }
}

/// Model cho response trạng thái thanh toán
class PaymentStatusResponse {
  final String status; // "pending", "paid", "cancelled", "failed"
  final String orderId;
  final double amount;
  final String? transactionId;

  PaymentStatusResponse({
    required this.status,
    required this.orderId,
    required this.amount,
    this.transactionId,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PaymentStatusResponse(
      status: data['payment_status'] ?? data['status'] ?? 'pending',
      orderId: data['order_id'] ?? data['orderId'] ?? '',
      amount: (data['amount'] ?? data['final_amount'] ?? 0).toDouble(),
      transactionId: data['transaction_id'] ?? data['transactionId'],
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed' || status.toLowerCase() == 'cancelled';
}

class PayOSApi {
  static final Dio _dio = ApiConfig.dio;
  static const String _createPaymentEndpoint = '/payments/payos/create';
  static const String _getPaymentStatusEndpoint = '/payments';

  /// Tạo payment link PayOS
  /// [orderId] - UUID của đơn hàng từ POST /orders
  static Future<PayOSCreateResponse> createPaymentLink(String orderId) async {
    try {
      final response = await _dio.post(
        _createPaymentEndpoint,
        data: {'order_id': orderId},
      );

      if (response.data != null) {
        return PayOSCreateResponse.fromJson(response.data);
      }

      throw Exception('Không nhận được payment link từ PayOS');
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Lỗi kết nối PayOS';
      throw Exception('Lỗi tạo payment link: $errorMessage');
    } catch (e) {
      throw Exception('Lỗi không xác định khi tạo payment link: $e');
    }
  }

  /// Kiểm tra trạng thái thanh toán
  /// [orderId] - UUID của đơn hàng
  static Future<PaymentStatusResponse> getPaymentStatus(String orderId) async {
    try {
      final response = await _dio.get('$_getPaymentStatusEndpoint/$orderId');

      if (response.data != null) {
        return PaymentStatusResponse.fromJson(response.data);
      }

      throw Exception('Không nhận được trạng thái thanh toán');
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Lỗi kết nối server';
      throw Exception('Lỗi kiểm tra trạng thái: $errorMessage');
    } catch (e) {
      throw Exception('Lỗi không xác định khi kiểm tra trạng thái: $e');
    }
  }
}