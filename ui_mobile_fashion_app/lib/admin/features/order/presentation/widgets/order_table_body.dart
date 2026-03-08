// lib/admin/features/order/presentation/widgets/order_table_body.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_mobile_fashion_app/admin/features/notification/widgets/custom_toast.dart';
import '../../data/admin_order_api.dart';
import '../../data/models/admin_order_model.dart';
import 'status_chip.dart';

class OrderTableBody extends StatefulWidget {
  final List<AdminOrder> orders;
  final double availableWidth;

  const OrderTableBody({
    super.key,
    required this.orders,
    required this.availableWidth,
  });

  @override
  State<OrderTableBody> createState() => _OrderTableBodyState();
}

class _OrderTableBodyState extends State<OrderTableBody> {
  // Lưu trạng thái local để cập nhật UI tức thì không cần reload toàn bộ danh sách
  late List<String> _statuses;

  // Theo dõi các row đang loading (tránh double-tap)
  final Set<int> _loadingIndexes = {};

  @override
  void initState() {
    super.initState();
    _statuses = widget.orders.map((o) => o.status).toList();
  }

  @override
  void didUpdateWidget(OrderTableBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi danh sách orders được reload từ bên ngoài thì đồng bộ lại
    if (oldWidget.orders != widget.orders) {
      _statuses = widget.orders.map((o) => o.status).toList();
    }
  }

  Future<void> _updateStatus(int index, String newStatus) async {
    final order = widget.orders[index];
    final oldStatus = _statuses[index];

    // Cập nhật UI tức thì (optimistic update)
    setState(() {
      _statuses[index] = newStatus;
      _loadingIndexes.add(index);
    });

    try {
      await AdminOrderApi.updateOrderStatus(
        orderId: order.id,
        newStatus: newStatus,
      );

      if (!mounted) return;

      CustomToast.show(
        context,
        message: 'Đã cập nhật trạng thái thành công',
        icon: Icons.check_circle_outline,
        backgroundColor: Colors.green.shade700,
      );
    } catch (e) {
      if (!mounted) return;

      // Rollback nếu API thất bại
      setState(() {
        _statuses[index] = oldStatus;
      });

      CustomToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline,
        backgroundColor: Colors.red.shade700,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingIndexes.remove(index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: widget.availableWidth,
        child: ListView.builder(
          itemCount: widget.orders.length,
          itemBuilder: (context, index) {
            final order = widget.orders[index];
            final isEven = index % 2 == 0;
            final isLoading = _loadingIndexes.contains(index);
            final currentStatus = _statuses[index];

            return Container(
              color: isEven ? const Color(0xFFF9FAFB) : Colors.white,
              height: 64,
              child: Row(
                children: [
                  // 1. STT
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // 2. Mã đơn
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black26,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // 3. Số điện thoại
                  SizedBox(
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        order.shippingPhone,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),

                  // 4. Giờ đặt
                  SizedBox(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(order.displayTime),
                    ),
                  ),

                  // 5. Ngày đặt
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(order.displayDate),
                    ),
                  ),

                  // 6. Cột Trạng thái (Dropdown)
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: isLoading
                        // Hiển thị spinner nhỏ khi đang gọi API
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                            : PopupMenuButton<String>(
                          tooltip: 'Thay đổi trạng thái',
                          offset: const Offset(0, 40),
                          child: StatusChip(
                            status: currentStatus,
                            isDropdown: true,
                          ),
                          onSelected: (String value) {
                            // Bỏ qua nếu chọn đúng trạng thái hiện tại
                            if (value == currentStatus) return;
                            _updateStatus(index, value);
                          },
                          itemBuilder: (BuildContext context) => [
                            _buildMenuItem('pending', 'Chờ xác nhận', Colors.orange),
                            _buildMenuItem('confirmed', 'Đã xác nhận', Colors.green),
                            _buildMenuItem('shipping', 'Đang giao', Colors.blue),
                            _buildMenuItem('delivered', 'Hoàn thành', Colors.green),
                            _buildMenuItem('cancelled', 'Đã hủy', Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 7. Tổng tiền
                  SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        currencyFormat.format(order.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),

                  // 8. Thao tác (Nút ba chấm)
                  SizedBox(
                    width: 100,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}