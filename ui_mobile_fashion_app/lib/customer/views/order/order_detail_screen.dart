// lib/customer/views/order/views/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ui_mobile_fashion_app/customer/logic/order/get_orders_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/order/order_response.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Order> _orderFuture;
  bool _isCancelling = false;

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  static const _statusConfigs = {
    'pending':   _StatusConfig(bg: Color(0xFFF5F5F5), fg: Color(0xFF757575), label: 'Chờ xử lý'),
    'shipped':   _StatusConfig(bg: Color(0xFF1A1A1A), fg: Color(0xFFFFFFFF), label: 'Đang giao'),
    'delivered': _StatusConfig(bg: Color(0xFF000000), fg: Color(0xFFFFFFFF), label: 'Đã giao'),
    'cancelled': _StatusConfig(bg: Color(0xFFEEEEEE), fg: Color(0xFF9E9E9E), label: 'Đã hủy'),
  };

  _StatusConfig _getStatusConfig(String status) =>
      _statusConfigs[status.toLowerCase()] ??
          const _StatusConfig(bg: Color(0xFFF5F5F5), fg: Color(0xFF757575), label: 'Khác');

  static const _paymentMethodLabels = {
    'cod': 'Thanh toán khi nhận hàng (COD)',
    'bank_transfer': 'Chuyển khoản ngân hàng',
    'credit_card': 'Thẻ tín dụng',
    'momo': 'Ví MoMo',
    'zalopay': 'ZaloPay',
  };

  @override
  void initState() {
    super.initState();
    _orderFuture = GetOrdersApi.getOrderDetail(widget.orderId);
  }

  Future<void> _cancelOrder(Order order) async {
    final reasonController = TextEditingController();
    String? confirmedReason;

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hủy đơn hàng?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D0D0D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '#${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(
                      fontSize: 13.5, color: Color(0xFF1A1A1A)),
                  decoration: InputDecoration(
                    hintText: 'Lý do hủy (ví dụ: Đặt nhầm sản phẩm)',
                    hintStyle: const TextStyle(
                        fontSize: 13.5, color: Color(0xFFBBBBBB)),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                      const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                      const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                      const BorderSide(color: Color(0xFF0D0D0D)),
                    ),
                    counterStyle: const TextStyle(
                        fontSize: 11, color: Color(0xFFBBBBBB)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius:
                            BorderRadius.all(Radius.circular(6)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Không',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          confirmedReason =
                              reasonController.text.trim();
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D0D0D),
                            borderRadius:
                            BorderRadius.all(Radius.circular(6)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Xác nhận hủy',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Dispose SAU KHI dialog đã đóng hoàn toàn
    reasonController.dispose();

    // Nếu người dùng bấm "Không" thì confirmedReason vẫn null → thoát
    if (confirmedReason == null) return;

    setState(() => _isCancelling = true);
    try {
      await GetOrdersApi.cancelOrder(order.id, reason: confirmedReason!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn hàng thành công'),
          backgroundColor: Color(0xFF1A1A1A),
        ),
      );
      setState(() {
        _orderFuture = GetOrdersApi.getOrderDetail(widget.orderId);
        _isCancelling = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFF1A1A1A),
        ),
      );
      setState(() => _isCancelling = false);
    }
  }

  // ─── Section tiêu đề ──────────────────────────────────────────────────────
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9E9E9E),
        letterSpacing: 0.8,
      ),
    ),
  );

  // ─── Row thông tin ─────────────────────────────────────────────────────────
  Widget _infoRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    ),
  );

  // ─── Item sản phẩm ────────────────────────────────────────────────────────
  Widget _buildProductItem(OrderItem item, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: item.fullProductImageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: const Color(0xFFF0F0F0),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Colors.black26),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFF0F0F0),
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.black26, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFAAAAAA)),
                    ),
                    Text(
                      _currency.format(item.subtotal),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  _currency.format(item.price) + '/sp',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFBBBBBB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Divider mỏng ─────────────────────────────────────────────────────────
  Widget _divider() => const Divider(
      height: 1, thickness: 1, color: Color(0xFFF2F2F2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D0D0D),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 19, color: Color(0xFF0D0D0D)),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: FutureBuilder<Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Colors.black, strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F0F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wifi_off_rounded,
                          size: 32, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Không thể tải đơn hàng',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFAAAAAA), fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => setState(() {
                        _orderFuture =
                            GetOrdersApi.getOrderDetail(widget.orderId);
                      }),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Thử lại',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = snapshot.data!;
          final config = _getStatusConfig(order.status);
          final canCancel = order.status.toLowerCase() == 'pending';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // ── Mã đơn + Trạng thái ──────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${order.orderNumber}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0D0D0D),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'Mã: ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFAAAAAA)),
                                  ),
                                  Text(
                                    '${order.orderCode}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFAAAAAA)),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: '${order.orderCode}'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                          Text('Đã sao chép mã đơn hàng'),
                                          backgroundColor: Color(0xFF1A1A1A),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                        Icons.copy_outlined,
                                        size: 13,
                                        color: Color(0xFFAAAAAA)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: config.bg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            config.label,
                            style: TextStyle(
                              color: config.fg,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: Color(0xFFBBBBBB)),
                        const SizedBox(width: 6),
                        Text(
                          'Đặt lúc ${DateFormat('HH:mm · dd/MM/yyyy').format(order.createdAt)}',
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Địa chỉ giao hàng ─────────────────────────────────────────
              _sectionTitle('ĐỊA CHỈ GIAO HÀNG'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shippingName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D0D0D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingPhone,
                      style: const TextStyle(
                          fontSize: 13.5, color: Color(0xFF757575)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        order.shippingAddress,
                        order.shippingWard,
                        order.shippingDistrict,
                        order.shippingProvince,
                      ].where((s) => s.isNotEmpty).join(', '),
                      style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF757575),
                          height: 1.45),
                    ),
                  ],
                ),
              ),

              // ── Sản phẩm ─────────────────────────────────────────────────
              _sectionTitle('SẢN PHẨM (${order.items.length})'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: order.items.asMap().entries.map((e) {
                    return _buildProductItem(e.value,
                        isLast: e.key == order.items.length - 1);
                  }).toList(),
                ),
              ),

              // ── Thanh toán ───────────────────────────────────────────────
              _sectionTitle('THANH TOÁN'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      'Hình thức',
                      _paymentMethodLabels[order.paymentMethod] ??
                          order.paymentMethod,
                    ),
                    _divider(),
                    const SizedBox(height: 10),
                    _infoRow(
                        'Tiền hàng', _currency.format(order.totalAmount)),
                    _infoRow(
                        'Phí vận chuyển', _currency.format(order.shippingFee)),
                    if (order.discountAmount > 0)
                      _infoRow('Giảm giá',
                          '- ${_currency.format(order.discountAmount)}'),
                    const SizedBox(height: 2),
                    _divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D0D0D),
                          ),
                        ),
                        Text(
                          _currency.format(order.finalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D0D0D),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Ghi chú ──────────────────────────────────────────────────
              if (order.note.isNotEmpty) ...[
                _sectionTitle('GHI CHÚ'),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    order.note,
                    style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF757575),
                        height: 1.5),
                  ),
                ),
              ],

              // ── Nút hủy đơn ──────────────────────────────────────────────
              if (canCancel) ...[
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _isCancelling ? null : () => _cancelOrder(order),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isCancelling
                          ? const Color(0xFFF2F2F2)
                          : const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: _isCancelling
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black38),
                    )
                        : const Text(
                      'Hủy đơn hàng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatusConfig {
  final Color bg;
  final Color fg;
  final String label;
  const _StatusConfig({required this.bg, required this.fg, required this.label});
}