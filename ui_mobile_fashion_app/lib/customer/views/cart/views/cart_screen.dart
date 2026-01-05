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

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tách riêng hàm load để dùng cho cả initState và RefreshIndicator
  Future<CartResponse> _loadData() {
    _cartFuture = CartApi.getCart();
    return _cartFuture;
  }

  void _refreshCart() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CartResponse>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
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
                  const Text('Không thể tải giỏ hàng'),
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
        // Bọc toàn bộ body bằng RefreshIndicator để hỗ trợ vuốt xuống tải lại
        return RefreshIndicator(
          onRefresh: () async {
            _refreshCart();
            await _cartFuture; // Đợi load xong để tắt cái vòng xoay refresh
          },
          color: Colors.black,
          child:
              cart.items.isNotEmpty
                  ? _buildCartWithItems(cart)
                  : _buildEmptyCart(),
        );
      },
    );
  }

  Widget _buildCartWithItems(CartResponse cart) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              // Physics này cực kỳ quan trọng để RefreshIndicator hoạt động được ngay cả khi danh sách ngắn
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return CartProductItem(item: item, onUpdate: _refreshCart);
              },
            ),
          ),
          _buildFooter(cart),
        ],
      ),
    );
  }

  Widget _buildFooter(CartResponse cart) {
    return Container(
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/order', extra: cart),
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
    );
  }

  Widget _buildEmptyCart() {
    return ListView(
      // Dùng ListView để vuốt xuống tải lại được
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Assets.customer.images.happyShopping.image(
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                'Giỏ hàng của bạn trống',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
