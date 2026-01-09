// lib/admin/features/order/presentation/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import '../mock_data/order_mock_data.dart';
import '../widgets/order_filter_tabs.dart';
import '../widgets/order_table_header.dart';
import '../widgets/order_table_body.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String _selectedStatus = 'Tất cả';

  List<OrderMock> get _filteredOrders {
    if (_selectedStatus == 'Tất cả') return mockOrders;
    return mockOrders
        .where((order) => order.status == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản Lý Đơn Hàng',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 24),

            OrderFilterTabs(
              selectedStatus: _selectedStatus,
              onStatusChanged:
                  (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;

                  return Column(
                    children: [
                      OrderTableHeader(width: availableWidth),
                      Expanded(
                        child: Container(
                          width: availableWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: OrderTableBody(
                            orders: _filteredOrders,
                            availableWidth: availableWidth,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
