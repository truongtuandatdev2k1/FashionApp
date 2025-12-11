// lib/customer/views/cart/views/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';
import '../../../logic/cart/cart_api.dart';
import '../widgets/cart_product_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<CartResponse> _cartFuture;

  // Sửa lỗi ở đây: dùng '₫' thay vì 'đ' để tránh lỗi ký tự
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  @override
  void initState() {
    super.initState();
    _cartFuture = CartApi.getCart();
  }

  void _refreshCart() {
    setState(() {
      _cartFuture = CartApi.getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CartResponse>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  TextButton(
                    onPressed: _refreshCart,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final cart = snapshot.data!;
        final hasItems = cart.items.isNotEmpty;

        return hasItems ? _buildCartWithItems(cart) : _buildEmptyCart();
      },
    );
  }

  // ================= GIỎ HÀNG CÓ SẢN PHẨM =================
  Widget _buildCartWithItems(CartResponse cart) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return CartProductItem(item: item, onUpdate: _refreshCart);
              },
            ),
          ),

          // Footer tổng tiền + nút thanh toán
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng cộng (${cart.totalItems} sản phẩm)',
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                      ),
                      Text(
                        _currency.format(cart.totalAmount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/order', extra: cart);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Thanh toán',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= GIỎ HÀNG RỖNG =================
  Widget _buildEmptyCart() {
    const double circleSize = 200.0;
    const double imageContentSize = 100.0;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Assets.customer.images.happyShopping.image(
                    width: imageContentSize,
                    height: imageContentSize,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Giỏ hàng của bạn\nhiện chưa có sản phẩm nào',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục mua sắm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
