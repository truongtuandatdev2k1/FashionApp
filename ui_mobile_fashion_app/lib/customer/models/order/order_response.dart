// lib/customer/models/order/order_response.dart
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';

class OrderItem {
  final String id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double subtotal;

  String get fullProductImageUrl => '${AppConfig.imageBaseUrl}$productImage';

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final int orderCode;
  final int customerId;
  final int shopId;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final String shippingProvince;
  final String shippingDistrict;
  final String shippingWard;
  final List<OrderItem> items;
  final double totalAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderCode,
    required this.customerId,
    required this.shopId,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.shippingProvince,
    required this.shippingDistrict,
    required this.shippingWard,
    required this.items,
    required this.totalAmount,
    required this.shippingFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>;
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      orderCode: json['order_code'] as int,
      customerId: json['customer_id'] as int,
      shopId: json['shop_id'] as int,
      shippingName: json['shipping_name'] as String,
      shippingPhone: json['shipping_phone'] as String,
      shippingAddress: json['shipping_address'] as String,
      shippingProvince: json['shipping_province'] as String,
      shippingDistrict: json['shipping_district'] as String,
      shippingWard: json['shipping_ward'] as String,
      items: itemsJson.map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      finalAmount: (json['final_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      status: json['status'] as String,
      note: json['note'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }
}

class OrderListResponse {
  final List<Order> orders;
  final int total;
  final int limit;
  final int offset;

  OrderListResponse({
    required this.orders,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final List<dynamic> ordersJson = data['orders'] as List<dynamic>;

    return OrderListResponse(
      orders: ordersJson.map((order) => Order.fromJson(order)).toList(),
      total: data['total'] as int,
      limit: data['limit'] as int,
      offset: data['offset'] as int,
    );
  }
}

class OrderDetailResponse {
  final Order order;

  OrderDetailResponse({required this.order});

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      order: Order.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}