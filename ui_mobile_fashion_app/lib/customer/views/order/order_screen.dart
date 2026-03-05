// lib/customer/views/order/order_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ui_mobile_fashion_app/customer/logic/cart/cart_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_default_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/order/create_order_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/payment/payos_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/order/order_request.dart';

import 'widgets/order_address_section.dart';
import 'widgets/order_product_item.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/order_payment_method_section.dart';
import 'widgets/order_bottom_bar.dart';

class OrderScreen extends StatefulWidget {
  final CartResponse cart;
  const OrderScreen({super.key, required this.cart});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with WidgetsBindingObserver {
  String _paymentMethod = 'cod';
  String? _pendingOrderId;
  bool _isCheckingPayment = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        _pendingOrderId != null &&
        !_isCheckingPayment) {
      _checkPaymentStatus();
    }
  }

  // ─── Payment status check ─────────────────────────────────────────────────

  Future<void> _checkPaymentStatus() async {
    if (_pendingOrderId == null || _isCheckingPayment) return;

    setState(() => _isCheckingPayment = true);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Row(children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text('Đang kiểm tra trạng thái thanh toán...'),
        ]),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      final status = await PayOSApi.getPaymentStatus(_pendingOrderId!);
      final totalAmount = widget.cart.totalAmount + 30000;

      if (!mounted) return;
      messenger.hideCurrentSnackBar();

      if (status.isPaid) {
        context.pushReplacement('/order-success', extra: {
          'orderId': _pendingOrderId,
          'totalAmount': totalAmount,
        });
      } else if (status.isFailed) {
        context.pushReplacement('/order-failure', extra: {
          'orderId': _pendingOrderId,
          'totalAmount': totalAmount,
          'error': 'Giao dịch bị hủy hoặc thất bại.',
        });
      } else {
        _showPaymentPendingDialog(totalAmount);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            'Lỗi kiểm tra trạng thái: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.orange,
        ));
    } finally {
      if (mounted) setState(() => _isCheckingPayment = false);
    }
  }

  void _showPaymentPendingDialog(double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Thanh toán đang chờ xử lý'),
        content: const Text(
          'Hệ thống chưa nhận được xác nhận thanh toán.\n\n'
              'Bạn muốn:\n'
              '• Kiểm tra lại trạng thái\n'
              '• Quay lại màn hình đặt hàng\n'
              '• Xem đơn hàng đã tạo',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/profile/my-orders');
            },
            child: const Text('Xem đơn hàng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _pendingOrderId = null);
            },
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _checkPaymentStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kiểm tra lại'),
          ),
        ],
      ),
    );
  }

  // ─── Open payment link ────────────────────────────────────────────────────

  Future<void> _openPaymentLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Không thể mở link thanh toán');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi mở link: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ─── Place order ──────────────────────────────────────────────────────────

  Future<void> _handlePlaceOrder() async {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Row(children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text('Đang xử lý đơn hàng...'),
        ]),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      // 1. Lấy địa chỉ mặc định
      final defaultAddress = await AddressDefaultApi.getDefaultAddress();
      if (defaultAddress == null) {
        throw Exception('Vui lòng chọn hoặc thêm địa chỉ giao hàng mặc định.');
      }

      // 2. Lấy danh sách cart item IDs
      final cartItemIds = widget.cart.items.map((item) => item.id).toList();
      if (cartItemIds.isEmpty) {
        throw Exception('Giỏ hàng hiện tại không có sản phẩm nào.');
      }

      // 3. Tạo request
      final orderRequest = CreateOrderRequest(
        addressId: defaultAddress.id,
        cartItemIds: cartItemIds,
        paymentMethod: _paymentMethod == 'bank_transfer' ? 'bank_transfer' : 'cod',
        note: null,
      );

      // 4. Xử lý theo phương thức thanh toán
      if (_paymentMethod == 'cod') {
        await CreateOrderApi.createOrder(orderRequest);
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        context.pushReplacement('/order-success');
      } else {
        // PayOS flow
        print('📦 Tạo đơn hàng với payment_method: bank_transfer');
        final orderId = await CreateOrderApi.createOrder(orderRequest);
        print('✅ Order ID: $orderId');
        if (!mounted) return;

        setState(() => _pendingOrderId = orderId);

        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Row(children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text('Đang tạo link thanh toán PayOS...'),
            ]),
            duration: Duration(seconds: 10),
          ),
        );

        print('🔗 Tạo payment link cho order: $orderId');
        final paymentLink = await PayOSApi.createPaymentLink(orderId);
        print('✅ Payment link: ${paymentLink.checkoutUrl}');

        if (!mounted) return;
        messenger.hideCurrentSnackBar();

        final shouldOpen = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Chuyển đến thanh toán'),
            content: const Text(
              'Bạn sẽ được chuyển đến trang PayOS để hoàn tất thanh toán.\n\n'
                  'Sau khi thanh toán xong, vui lòng quay lại ứng dụng để kiểm tra trạng thái.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tiếp tục'),
              ),
            ],
          ),
        );

        if (shouldOpen == true && mounted) {
          print('🌐 Mở payment link...');
          await _openPaymentLink(paymentLink.checkoutUrl);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Vui lòng hoàn tất thanh toán trên trình duyệt'),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          setState(() => _pendingOrderId = null);
        }
      }
    } catch (e) {
      if (!mounted) return;
      final errorString = e.toString().replaceFirst('Exception: ', '');
      print('❌ Lỗi đặt hàng: $errorString');

      messenger.hideCurrentSnackBar();

      // Idempotent: cart rỗng sau khi đã đặt hàng COD thành công
      if (errorString.contains('cart is empty') && _paymentMethod == 'cod') {
        context.pushReplacement('/order-success');
        return;
      }

      context.pushReplacement('/order-failure', extra: errorString);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cart.items;
    final totalAmount = widget.cart.totalAmount;
    final totalItems = widget.cart.totalItems;

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const OrderAddressSection(),
            _divider(thickness: 8),
            ...cartItems.map((item) => Column(
              children: [
                OrderProductItem(item: item),
                if (item != cartItems.last)
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
              ],
            )),
            _divider(thickness: 8),
            OrderSummarySection(subtotal: totalAmount, totalItems: totalItems),
            _divider(thickness: 8),
            OrderPaymentMethodSection(
              selectedMethod: _paymentMethod,
              onChanged: (val) => setState(() => _paymentMethod = val),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: OrderBottomBar(
        subtotal: totalAmount,
        totalItems: totalItems,
        onPlaceOrder: _handlePlaceOrder,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Tổng quan đơn hàng'),
      centerTitle: true,
      elevation: 0.5,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock, size: 14, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'Thông tin bạn sẽ được bảo mật và mã hóa',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider({double thickness = 1}) {
    return Divider(height: 1, thickness: thickness, color: const Color(0xFFF5F5F5));
  }
}