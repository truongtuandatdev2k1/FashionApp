// lib/admin/features/order/presentation/widgets/order_table_body.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../mock_data/order_mock_data.dart';
import 'status_chip.dart';
import 'order_empty_view.dart';

// Widget chip cho trạng thái thanh toán (tách riêng cho dễ quản lý)
Widget _buildPaymentChip(String paymentStatus) {
  final isPaid = paymentStatus == 'Đã thanh toán';
  final color = isPaid ? Colors.green : Colors.orange;
  final icon = isPaid ? Icons.check_circle_outline : Icons.hourglass_empty;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(paymentStatus, style: TextStyle(color: color, fontSize: 13)),
      ],
    ),
  );
}

class OrderTableBody extends StatelessWidget {
  final List<OrderMock> orders;
  final double availableWidth;

  const OrderTableBody({
    super.key,
    required this.orders,
    required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const OrderEmptyView();
    }

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
              color: isEven ? const Color(0xFFF9FAFB) : Colors.white,
              height: 64,
              child: Row(
                children: [
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
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        order.id,
                        style: const TextStyle(
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black45,
                          decorationThickness: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        order.customer,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(order.phone),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(order.time),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(order.date),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(
                        order.quantity.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StatusChip(status: order.status),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        currencyFormat.format(order.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  // Cột Trạng thái thanh toán mới
                  SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPaymentChip(order.paymentStatus),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, size: 20),
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
}
