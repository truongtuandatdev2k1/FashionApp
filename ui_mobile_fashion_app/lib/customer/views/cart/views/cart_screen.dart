// lib/customer/views/cart/views/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';
import '../../../logic/cart/cart_mock_data.dart';
import '../widgets/cart_product_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Widget khi giỏ hàng rỗng
  Widget _buildEmptyCart() {
    const double circleSize = 200.0;
    const double imageContentSize = 100.0;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Hình tròn + ảnh happy shopping
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
                    fit: BoxFit.contain,
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
                  onPressed: () {
                    debugPrint('Tiếp tục mua sắm');
                    // TODO: Navigate về trang chủ
                  },
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

  // Widget khi có sản phẩm
  Widget _buildCartWithItems() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: CartMockData.items.length,
              itemBuilder: (context, index) {
                final product = CartMockData.items[index];
                return CartProductItem(product: product);
              },
            ),
          ),
          // Footer tổng tiền + nút thanh toán (có thể mở rộng sau)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng cộng', style: TextStyle(color: Colors.grey)),
                      Text(
                        '2.554.000₫',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('Thanh toán');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Thanh toán',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final hasItems = CartMockData.items.isNotEmpty;
    return hasItems ? _buildCartWithItems() : _buildEmptyCart();
  }
}