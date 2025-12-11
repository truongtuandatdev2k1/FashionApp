// lib/customer/logic/cart/cart_api.dart

import 'package:dio/dio.dart';
import 'package:ui_mobile_fashion_app/core/di/locator.dart';

class CartItem {
  final int id;
  final int quantity;
  final double currentPrice;
  final double subtotal;
  final ProductInCart product;

  CartItem({
    required this.id,
    required this.quantity,
    required this.currentPrice,
    required this.subtotal,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['quantity'],
      currentPrice: json['current_price'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      product: ProductInCart.fromJson(json['product']),
    );
  }
}

class ProductInCart {
  final int productId;
  final String name;
  final String sku;
  final String color;
  final String size;
  final String imageUrl;
  final int stock;

  ProductInCart({
    required this.productId,
    required this.name,
    required this.sku,
    required this.color,
    required this.size,
    required this.imageUrl,
    required this.stock,
  });

  String get fullImageUrl => 'http://160.191.244.37:4003$imageUrl';

  factory ProductInCart.fromJson(Map<String, dynamic> json) {
    return ProductInCart(
      productId: json['product_id'],
      name: json['name'],
      sku: json['sku'],
      color: json['color'],
      size: json['size'],
      imageUrl: json['image_url'],
      stock: json['stock'],
    );
  }
}

class CartResponse {
  final List<CartItem> items;
  final int totalItems;
  final double totalAmount;

  CartResponse({
    required this.items,
    required this.totalItems,
    required this.totalAmount,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<CartItem> items = list.map((i) => CartItem.fromJson(i)).toList();

    return CartResponse(
      items: items,
      totalItems: json['total_items'],
      totalAmount: json['total_amount'].toDouble(),
    );
  }
}

class CartApi {
  static final _dio = getIt<Dio>();

  static Future<CartResponse> getCart() async {
    try {
      final response = await _dio.get('/cart');
      if (response.data['code'] == 'OK') {
        return CartResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Lấy giỏ hàng thất bại');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng');
    }
  }

  // TODO: Sau này thêm update quantity, delete item
}
