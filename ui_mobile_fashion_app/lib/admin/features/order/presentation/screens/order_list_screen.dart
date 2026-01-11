// lib/admin/features/order/presentation/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import '../../data/admin_order_api.dart';
import '../../data/models/admin_order_model.dart';
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
  late Future<AdminOrderListResponse> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    // Map trạng thái từ UI sang API status
    String? apiStatus;
    if (_selectedStatus != 'Tất cả') {
      switch (_selectedStatus) {
        case 'Chờ xác nhận':
          apiStatus = 'pending';
          break;
        case 'Đã xác nhận':
          apiStatus = 'confirmed';
          break;
        case 'Đang giao':
          apiStatus = 'shipping';
          break;
        case 'Hoàn thành':
          apiStatus = 'delivered';
          break;
        case 'Đã hủy':
          apiStatus = 'cancelled';
          break;
      }
    }

    setState(() {
      _ordersFuture = AdminOrderApi.getOrders(
        limit: 20,
        offset: 0,
        status: apiStatus,
      );
    });
  }

  void _onStatusChanged(String newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
    _loadOrders();
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quản Lý Đơn Hàng',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadOrders,
                  tooltip: 'Làm mới',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Tabs
            OrderFilterTabs(
              selectedStatus: _selectedStatus,
              onStatusChanged: _onStatusChanged,
            ),
            const SizedBox(height: 24),

            // Table with Data
            Expanded(
              child: FutureBuilder<AdminOrderListResponse>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không thể tải đơn hàng',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error
                                .toString()
                                .replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadOrders,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có đơn hàng nào',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy chọn tab khác hoặc thử lại sau',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = snapshot.data!.orders;

                  return LayoutBuilder(
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
                                orders: orders,
                                availableWidth: availableWidth,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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