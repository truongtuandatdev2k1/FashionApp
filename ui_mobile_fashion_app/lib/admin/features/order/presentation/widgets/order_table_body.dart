// lib/admin/features/order/presentation/widgets/order_table_body.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_mobile_fashion_app/admin/features/notification/widgets/custom_toast.dart';
import '../../data/models/admin_order_model.dart';
import 'status_chip.dart';

class OrderTableBody extends StatelessWidget {
  final List<AdminOrder> orders;
  final double availableWidth;

  const OrderTableBody({
    super.key,
    required this.orders,
    required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng tiền tệ Việt Nam (1.000.000 ₫)
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: availableWidth,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isEven = index % 2 == 0;

            return Container(
              // Đổ màu xen kẽ giữa các dòng cho dễ nhìn
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
                  // Cột Trạng thái (Dropdown)
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<String>(
                          tooltip: 'Thay đổi trạng thái',
                          offset: const Offset(0, 40),
                          child: StatusChip(
                            status: order.status,
                            isDropdown: true,
                          ),
                          onSelected: (String value) {
                            // GỌI THÔNG BÁO TÙY CHỈNH TẠI ĐÂY
                            CustomToast.show(
                              context,
                              message: 'Tính năng chưa được phát triển',
                              icon: Icons.info_outline,
                              backgroundColor: Colors.blueGrey.shade800,
                            );
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
                        onPressed: () {
                          // Log hoặc xử lý mở chi tiết đơn hàng
                        },
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

  /// Hàm helper tạo item cho menu lựa chọn
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
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}