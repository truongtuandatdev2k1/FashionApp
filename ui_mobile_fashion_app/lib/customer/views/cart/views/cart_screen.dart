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

  // Lưu các item được chọn (dùng id)
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<CartResponse> _loadData() {
    _cartFuture = CartApi.getCart();
    return _cartFuture;
  }

  void _refreshCart() {
    setState(() {
      _loadData();
      // Nếu muốn reset chọn khi refresh thì uncomment dòng dưới
      // _selectedIds.clear();
    });
  }

  double _calculateSelectedTotal(CartResponse cart) {
    double total = 0;
    for (final item in cart.items) {
      if (_selectedIds.contains(item.id)) {
        total += item.currentPrice * item.quantity;
      }
    }
    return total;
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

        final selectedCount = _selectedIds.length;
        final totalAmount = selectedCount > 0
            ? _calculateSelectedTotal(cart)
            : cart.totalAmount;

        return RefreshIndicator(
          onRefresh: () async {
            _refreshCart();
            await _cartFuture;
          },
          color: Colors.black,
          child: Scaffold(
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
            body: cart.items.isEmpty
                ? _buildEmptyCart()
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartProductItem(
                        item: item,
                        onUpdate: _refreshCart,
                        onSelectionChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedIds.add(item.id as String);
                            } else {
                              _selectedIds.remove(item.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                _buildFooter(cart, selectedCount, totalAmount),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(CartResponse cart, int selectedCount, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -3),
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
                  selectedCount > 0
                      ? 'Đã chọn $selectedCount/${cart.totalItems} sản phẩm'
                      : 'Tổng cộng (${cart.totalItems} sản phẩm)',
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
                Text(
                  _currency.format(totalAmount),
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
                onPressed: selectedCount == 0
                    ? null
                    : () {
                  // Có thể filter chỉ gửi các item được chọn
                  context.push('/order', extra: cart);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: selectedCount == 0 ? Colors.white70 : Colors.white,
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