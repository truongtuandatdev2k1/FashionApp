// lib/customer/views/order/order_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';

import 'package:ui_mobile_fashion_app/customer/logic/cart/cart_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_default_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/order/create_order_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/payment/payos_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/order/order_request.dart';

import 'widgets/order_address_section.dart';
import 'widgets/order_product_item.dart';

class OrderScreen extends StatefulWidget {
  final CartResponse cart;
  const OrderScreen({super.key, required this.cart});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with WidgetsBindingObserver {
  String _paymentMethod = 'cod';
  String? _pendingOrderId; // Lưu order ID đang chờ thanh toán PayOS
  bool _isCheckingPayment = false;

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

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

  /// Được gọi khi app quay lại từ background (sau khi mở PayOS web)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Khi app resumed và đang có order đang chờ thanh toán
    if (state == AppLifecycleState.resumed &&
        _pendingOrderId != null &&
        !_isCheckingPayment) {
      _checkPaymentStatus();
    }
  }

  // ====================== LOGIC KIỂM TRA TRẠNG THÁI THANH TOÁN ======================

  Future<void> _checkPaymentStatus() async {
    if (_pendingOrderId == null || _isCheckingPayment) return;

    setState(() => _isCheckingPayment = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Đang kiểm tra trạng thái thanh toán...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      final status = await PayOSApi.getPaymentStatus(_pendingOrderId!);
      final totalAmount = widget.cart.totalAmount + 30000;

      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      if (status.isPaid) {
        // Thanh toán thành công
        context.pushReplacement('/order-success', extra: {
          'orderId': _pendingOrderId,
          'totalAmount': totalAmount,
        });
      } else if (status.isFailed) {
        // Thanh toán thất bại
        context.pushReplacement('/order-failure', extra: {
          'orderId': _pendingOrderId,
          'totalAmount': totalAmount,
          'error': 'Giao dịch bị hủy hoặc thất bại.',
        });
      } else {
        // Vẫn đang pending - hiển thị dialog hỏi
        _showPaymentPendingDialog(totalAmount);
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi kiểm tra trạng thái: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingPayment = false);
      }
    }
  }

  void _showPaymentPendingDialog(double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              Navigator.of(context).pop();
              context.go('/profile/my-orders');
            },
            child: const Text('Xem đơn hàng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _pendingOrderId = null);
            },
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  // ====================== LOGIC MỞ PAYMENT LINK ======================

  Future<void> _openPaymentLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Mở trong browser
        );
      } else {
        throw Exception('Không thể mở link thanh toán');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi mở link: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ====================== LOGIC ĐẶT HÀNG ======================

  Future<void> _handlePlaceOrder() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final totalAmount = widget.cart.totalAmount + 1000; // + tiền ship

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Đang xử lý đơn hàng...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      // 1. Lấy địa chỉ mặc định
      final defaultAddress = await AddressDefaultApi.getDefaultAddress();
      if (defaultAddress == null) {
        throw Exception('Vui lòng chọn hoặc thêm địa chỉ giao hàng mặc định.');
      }
      final addressId = defaultAddress.id;

      // 2. Lấy danh sách ID sản phẩm
      final cartItemIds = widget.cart.items.map((item) => item.id).toList();
      if (cartItemIds.isEmpty) {
        throw Exception('Giỏ hàng hiện tại không có sản phẩm nào.');
      }

      // 3. Tạo Request Object - SỬA: bank_transfer thay vì bank
      final orderRequest = CreateOrderRequest(
        addressId: addressId,
        cartItemIds: cartItemIds,
        paymentMethod: _paymentMethod == 'bank_transfer' ? 'bank_transfer' : 'cod',
        note: null,
      );

      // 4. XỬ LÝ THEO PHƯƠNG THỨC THANH TOÁN
      if (_paymentMethod == 'cod') {
        // === THANH TOÁN KHI NHẬN HÀNG (COD) ===
        await CreateOrderApi.createOrder(orderRequest);
        if (!mounted) return;

        scaffoldMessenger.hideCurrentSnackBar();
        context.pushReplacement('/order-success');
      } else {
        // === THANH TOÁN QUA PAYOS ===

        // Bước 1: Tạo đơn hàng
        print('📦 Đang tạo đơn hàng với payment_method: bank_transfer');
        final orderId = await CreateOrderApi.createOrder(orderRequest);
        print('✅ Đơn hàng đã tạo thành công. Order ID: $orderId');

        if (!mounted) return;

        // Lưu order ID để kiểm tra sau
        setState(() => _pendingOrderId = orderId);

        // Bước 2: Tạo payment link từ PayOS
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Text('Đang tạo link thanh toán PayOS...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );

        print('🔗 Đang tạo payment link cho order: $orderId');
        final paymentLink = await PayOSApi.createPaymentLink(orderId);
        print('✅ Payment link đã tạo: ${paymentLink.checkoutUrl}');

        if (!mounted) return;
        scaffoldMessenger.hideCurrentSnackBar();

        // Bước 3: Hiển thị hướng dẫn và mở link
        final shouldOpen = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Chuyển đến thanh toán'),
            content: const Text(
              'Bạn sẽ được chuyển đến trang PayOS để hoàn tất thanh toán.\n\n'
                  'Sau khi thanh toán xong, vui lòng quay lại ứng dụng để kiểm tra trạng thái.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
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
          // Mở payment link
          print('🌐 Mở payment link trong browser...');
          await _openPaymentLink(paymentLink.checkoutUrl);

          // Hiển thị snackbar nhắc nhở
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Vui lòng hoàn tất thanh toán trên trình duyệt'),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // User hủy - reset pending order
          setState(() => _pendingOrderId = null);
        }
      }
    } catch (e) {
      if (!mounted) return;
      final errorString = e.toString().replaceFirst('Exception: ', '');
      print('❌ Lỗi đặt hàng: $errorString');

      // Handle riêng trường hợp Cart Empty (Idempotent) - CHỈ CHO COD
      if (errorString.contains('cart is empty') && _paymentMethod == 'cod') {
        scaffoldMessenger.hideCurrentSnackBar();
        context.pushReplacement('/order-success');
        return;
      }

      // Lỗi chung
      scaffoldMessenger.hideCurrentSnackBar();
      context.pushReplacement('/order-failure', extra: errorString);
    }
  }

  // ====================== GIAO DIỆN ======================

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cart.items;
    final totalAmount = widget.cart.totalAmount;
    final totalItems = widget.cart.totalItems;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
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
                Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Thông tin bạn sẽ được bảo mật và mã hóa',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const OrderAddressSection(),
            _buildDivider(thickness: 8),
            ...cartItems.map((item) {
              return Column(
                children: [
                  OrderProductItem(item: item),
                  if (item != cartItems.last)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              );
            }).toList(),
            _buildDivider(thickness: 8),
            _buildDeliveryGuaranteeSection(context),
            _buildDivider(thickness: 8),
            _buildOrderSummarySection(context, totalAmount, totalItems),
            _buildDivider(thickness: 8),
            _buildPaymentMethodSection(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, totalAmount, totalItems),
    );
  }

  Widget _buildDivider({double thickness = 1}) {
    return Divider(
      height: 1,
      thickness: thickness,
      color: const Color(0xFFF5F5F5),
    );
  }

  Widget _buildDeliveryGuaranteeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Đảm bảo giao hàng: 25-26/3',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.black87,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Vận chuyển tiêu chuẩn', style: TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Nhận voucher giảm giá nếu được đơn hàng bị giao muộn',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(
      BuildContext context,
      double subtotal,
      int totalItems,
      ) {
    const double shippingFee = 1000;
    final double total = subtotal + shippingFee;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Tổng phụ (${totalItems} sp)',
            _currency.format(subtotal),
            isTotal: false,
          ),
          _buildSummaryRow(
            'Vận chuyển',
            _currency.format(shippingFee),
            isTotal: false,
          ),
          const Divider(),
          _buildSummaryRow('Tổng', _currency.format(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {required bool isTotal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildPaymentOption(
            icon: Icons.wallet_outlined,
            label: 'Thanh toán khi nhận hàng',
            value: 'cod',
          ),
          _buildPaymentOption(
            leading: Assets.customer.images.vnpay.image(
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            label: 'Thanh toán online qua PayOS',
            value: 'bank_transfer',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    Widget? leading,
    IconData? icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading ?? Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Radio<String>(
        value: value,
        groupValue: _paymentMethod,
        onChanged: (val) {
          if (val != null) {
            setState(() => _paymentMethod = val);
          }
        },
        activeColor: Colors.black,
      ),
      onTap: () {
        setState(() => _paymentMethod = value);
      },
    );
  }

  Widget _buildBottomBar(
      BuildContext context,
      double subtotal,
      int totalItems,
      ) {
    const double shippingFee = 1000;
    final double total = subtotal + shippingFee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Tổng (${totalItems} mặt hàng)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _currency.format(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _handlePlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Đặt hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}