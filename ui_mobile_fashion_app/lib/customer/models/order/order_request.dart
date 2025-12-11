// lib/customer/models/order_request.dart (Giả định)

class CreateOrderRequest {
  final int addressId;
  final List<int> cartItemIds;
  final String paymentMethod;
  final String? note; // Tạm thời không dùng

  CreateOrderRequest({
    required this.addressId,
    required this.cartItemIds,
    required this.paymentMethod,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'cart_item_ids': cartItemIds,
      'note': note,
      'payment_method': paymentMethod,
      // 'promotion_codes': [] // Tạm thời không cần
    };
  }
}
