// lib/customer/views/profile/views/my_order_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/customer/logic/order/get_orders_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/order/order_response.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  late Future<OrderListResponse> _ordersFuture;
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  // ─── Màu sắc trạng thái: chỉ dùng sắc độ xám / đen / trắng ──────────────
  static const _statusConfigs = {
    'pending':   _StatusConfig(bg: Color(0xFFF5F5F5), fg: Color(0xFF757575), label: 'Chờ xử lý'),
    'shipped':   _StatusConfig(bg: Color(0xFF1A1A1A), fg: Color(0xFFFFFFFF), label: 'Đang giao'),
    'delivered': _StatusConfig(bg: Color(0xFF000000), fg: Color(0xFFFFFFFF), label: 'Đã giao'),
    'cancelled': _StatusConfig(bg: Color(0xFFEEEEEE), fg: Color(0xFF9E9E9E), label: 'Đã hủy'),
  };

  _StatusConfig _getStatusConfig(String status) =>
      _statusConfigs[status.toLowerCase()] ??
          const _StatusConfig(bg: Color(0xFFF5F5F5), fg: Color(0xFF757575), label: 'Khác');

  // ─── Item sản phẩm ────────────────────────────────────────────────────────
  Widget _buildProductItem(OrderItem item, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm – bo góc vuông nhẹ
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: item.fullProductImageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFFF0F0F0),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.black38,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
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
                      'SL: ${item.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      _currency.format(item.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card đơn hàng ────────────────────────────────────────────────────────
  Widget _buildOrderCard(Order order) {
    final totalItems = order.items.fold<int>(0, (s, i) => s + i.quantity);
    final config = _getStatusConfig(order.status);
    final bool showBuyAgain = order.status.toLowerCase() == 'delivered';
    final displayedItems = order.items.take(3).toList();
    final hasMore = order.items.length > 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mã đơn hàng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('dd/MM/yyyy · HH:mm').format(order.createdAt),
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge trạng thái
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: config.bg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    config.label,
                    style: TextStyle(
                      color: config.fg,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider mỏng ──────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
          ),

          // ── Danh sách sản phẩm ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ...displayedItems.asMap().entries.map((entry) {
                  final bool isLast =
                      entry.key == displayedItems.length - 1 && !hasMore;
                  return _buildProductItem(entry.value, isLast: isLast);
                }),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.more_horiz,
                            size: 16, color: Color(0xFFBBBBBB)),
                        const SizedBox(width: 6),
                        Text(
                          '+${order.items.length - 3} sản phẩm khác',
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Divider + Tổng tiền ───────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$totalItems sản phẩm',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'Tổng  ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
                    ),
                    Text(
                      _currency.format(order.finalAmount),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D0D0D),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Nút hành động ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                if (showBuyAgain) ...[
                  Expanded(
                    child: _OutlineBtn(
                      label: 'Mua lại',
                      icon: Icons.replay_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang phát triển tính năng Mua lại'),
                            backgroundColor: Color(0xFF1A1A1A),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _FilledBtn(
                    label: 'Xem chi tiết',
                    onTap: () {
                      // TODO: Chuyển sang màn hình chi tiết đơn hàng
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của tôi',
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
      body: FutureBuilder<OrderListResponse>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // ── Loading ────────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Colors.black, strokeWidth: 2),
            );
          }

          // ── Error ──────────────────────────────────────────────────────────
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(36),
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
                        color: Color(0xFF1A1A1A),
                      ),
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
                    _FilledBtn(
                      label: 'Thử lại',
                      icon: Icons.refresh_rounded,
                      onTap: () => setState(
                              () => _ordersFuture = GetOrdersApi.getOrders()),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty ──────────────────────────────────────────────────────────
          if (!snapshot.hasData || snapshot.data!.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        size: 44, color: Color(0xFFBBBBBB)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chưa có đơn hàng nào',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Khi bạn đặt hàng, chúng sẽ hiện ở đây',
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
                  ),
                ],
              ),
            );
          }

          // ── List ───────────────────────────────────────────────────────────
          final orders = snapshot.data!.orders;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 28),
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderCard(orders[index]),
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

/// Nút viền – dùng cho "Mua lại"
class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _OutlineBtn({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: const Color(0xFF1A1A1A)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút đặc – dùng cho "Xem chi tiết" và "Thử lại"
class _FilledBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilledBtn({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}