// lib/customer/views/order/order_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// ***************************************************************
// IMPORTS CHO LOGIC XỬ LÝ ĐƠN HÀNG VÀ DỮ LIỆU
import 'package:ui_mobile_fashion_app/customer/logic/cart/cart_api.dart'; // CartResponse, CartItem
import 'package:ui_mobile_fashion_app/customer/logic/address/address_default_api.dart'; // Lấy địa chỉ mặc định
import 'package:ui_mobile_fashion_app/customer/logic/order/create_order_api.dart'; // API tạo đơn hàng
import 'package:ui_mobile_fashion_app/customer/models/order/order_request.dart';
// ***************************************************************

import 'widgets/order_address_section.dart';
import 'widgets/order_product_item.dart';

class OrderScreen extends StatefulWidget {
  final CartResponse cart;
  const OrderScreen({super.key, required this.cart});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _paymentMethod = 'cod'; // Đặt mặc định là COD để dễ test

  // Format tiền tệ
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  // ====================== LOGIC XỬ LÝ CHUYỂN MÀN HÌNH ======================

  // Hàm xử lý logic chuyển màn hình thành công
  void _onOrderSuccess(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (!mounted) return;

    // Ẩn SnackBar loading và chuyển hướng
    scaffoldMessenger.hideCurrentSnackBar();

    // CHUYỂN HƯỚNG ĐẾN MÀN HÌNH THÀNH CÔNG
    context.pushReplacement('/order-success');
  }

  // Hàm xử lý logic chuyển màn hình thất bại
  void _onOrderFailure(BuildContext context, String error) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (!mounted) return;

    // Ẩn SnackBar loading và chuyển hướng
    scaffoldMessenger.hideCurrentSnackBar();

    // CHUYỂN HƯỚNG ĐẾN MÀN HÌNH THẤT BẠI, TRUYỀN LỖI QUA 'extra'
    context.pushReplacement('/order-failure', extra: error);
  }

  // ====================== LOGIC ĐẶT HÀNG ======================

  Future<void> _handlePlaceOrder() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Kiểm tra phương thức thanh toán không hỗ trợ
    if (_paymentMethod != 'cod') {
      // In lỗi ra terminal theo yêu cầu
      print('-----------------------------------------');
      print(
        'LỖI ĐẶT HÀNG: Dịch vụ thanh toán qua ngân hàng hiện chưa được hỗ trợ.',
      );
      print('-----------------------------------------');
      _onOrderFailure(
        context,
        'Dịch vụ thanh toán qua ngân hàng hiện chưa được hỗ trợ.',
      );
      return;
    }

    // 2. Hiển thị loading
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
        duration: Duration(seconds: 10),
      ),
    );

    try {
      // 3. Lấy ID địa chỉ mặc định
      final defaultAddress = await AddressDefaultApi.getDefaultAddress();
      if (defaultAddress == null) {
        throw Exception('Vui lòng chọn hoặc thêm địa chỉ giao hàng mặc định.');
      }
      final addressId = defaultAddress.id;

      // 4. Lấy danh sách ID sản phẩm trong giỏ hàng
      final cartItemIds = widget.cart.items.map((item) => item.id).toList();

      if (cartItemIds.isEmpty) {
        // Kiểm tra client-side để tránh gọi API với giỏ hàng rỗng
        throw Exception('Giỏ hàng hiện tại không có sản phẩm nào.');
      }

      // 5. Tạo Request Object
      final orderRequest = CreateOrderRequest(
        addressId: addressId,
        cartItemIds: cartItemIds,
        paymentMethod: _paymentMethod,
        note: null, // Tạm thời không có note
      );

      // 6. Gọi API tạo đơn hàng
      await CreateOrderApi.createOrder(orderRequest);

      // 7. Xử lý thành công
      _onOrderSuccess(context);
    } catch (e) {
      if (!mounted) return;

      // Lấy chuỗi lỗi và loại bỏ "Exception: "
      final errorString = e.toString().replaceFirst('Exception: ', '');

      // BẮT LỖI IDEMPOTENT (Giỏ hàng đã rỗng do đơn hàng đã tạo trước đó)
      if (errorString.contains('cart is empty')) {
        // Xử lý như thành công
        _onOrderSuccess(context);
        return;
      }

      // Xử lý lỗi thất bại khác
      _onOrderFailure(context, errorString);
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
            // --- Phần 1: Địa chỉ giao hàng ---
            const OrderAddressSection(),
            _buildDivider(thickness: 8),

            // --- Phần 2: Danh sách sản phẩm ---
            ...cartItems.map((item) {
              return Column(
                children: [
                  OrderProductItem(item: item),
                  // Thêm Divider nếu không phải là item cuối cùng
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

            // --- Phần 3: Đảm bảo giao hàng ---
            _buildDeliveryGuaranteeSection(context),
            _buildDivider(thickness: 8),

            // --- Phần 4: Tóm tắt đơn hàng ---
            _buildOrderSummarySection(context, totalAmount, totalItems),
            _buildDivider(thickness: 8),

            // --- Phần 5: Phương thức thanh toán ---
            _buildPaymentMethodSection(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
      // --- Phần 6: Bottom Bar (Tổng tiền và Đặt hàng) ---
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
    const double shippingFee = 50000; // Phí vận chuyển cố định
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
          // Thanh toán khi nhận hàng (COD)
          _buildPaymentOption(
            icon: Icons.wallet_outlined,
            label: 'Thanh toán khi nhận hàng',
            value: 'cod',
          ),
          // Thanh toán qua ngân hàng
          _buildPaymentOption(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Thanh toán qua ngân hàng',
            value: 'bank',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Radio<String>(
        value: value,
        groupValue: _paymentMethod,
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _paymentMethod = val;
            });
          }
        },
        activeColor: Colors.black,
      ),
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    double subtotal,
    int totalItems,
  ) {
    const double shippingFee = 50000;
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
                _currency.format(total), // Dùng tổng cuối cùng
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          ElevatedButton(
            // GỌI HÀM XỬ LÝ ĐẶT HÀNG
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
