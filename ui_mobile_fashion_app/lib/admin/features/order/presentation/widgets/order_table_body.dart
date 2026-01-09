// lib/admin/features/order/presentation/widgets/order_table_body.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/admin/features/order/presentation/widgets/order_empty_view.dart';
import '../mock_data/order_mock_data.dart';
import 'status_chip.dart';

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
