// lib/admin/features/order/data/models/admin_order_model.dart

class AdminOrder {
  final String id;
  final String orderNumber;
  final String status;
  final String shippingPhone;
  final double totalAmount;
  final DateTime createdAt;

  AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.shippingPhone,
    required this.totalAmount,
    required this.createdAt,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      shippingPhone: json['shipping_phone'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Helper getters
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String get displayDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  String get displayTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

class AdminOrderListResponse {
  final List<AdminOrder> orders;
  final int total;
  final int limit;
  final int offset;

  AdminOrderListResponse({
    required this.orders,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory AdminOrderListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemsList = data['items'] as List<dynamic>;

    return AdminOrderListResponse(
      orders: itemsList.map((item) => AdminOrder.fromJson(item)).toList(),
      total: data['total'] as int,
      limit: data['limit'] as int,
      offset: data['offset'] as int,
    );
  }
}