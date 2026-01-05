// lib/admin/features/dashboard/presentation/screens/stats_screen.dart
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để hỗ trợ Responsive lưới thống kê
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Để lộ màu nền của MainLayout nếu cần
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng Quan Hệ Thống',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Hàng các thẻ thống kê
            _buildStatsGrid(screenWidth),

            const SizedBox(height: 32),
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Bảng dữ liệu
            _buildRecentActivityTable(),
          ],
        ),
      ),
    );
  }

  // Lưới các thẻ thống kê (Responsive dựa trên chiều rộng)
  Widget _buildStatsGrid(double width) {
    // Điều chỉnh số cột dựa trên độ rộng màn hình
    int crossAxisCount = width > 1200 ? 4 : (width > 800 ? 2 : 1);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: width > 400 ? 2.5 : 1.5, // Chỉnh tỉ lệ card cho mobile
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _buildStatCard(
          'Doanh Thu',
          '45,000,000đ',
          Icons.attach_money,
          Colors.blue,
        ),
        _buildStatCard('Đơn Hàng', '128', Icons.shopping_bag, Colors.orange),
        _buildStatCard('Sản Phẩm', '1,050', Icons.inventory, Colors.purple),
        _buildStatCard('Người Dùng', '850', Icons.group, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Hỗ trợ cuộn ngang nếu bảng quá rộng
        child: DataTable(
          columnSpacing: 40,
          columns: const [
            DataColumn(label: Text('Mã Đơn')),
            DataColumn(label: Text('Khách Hàng')),
            DataColumn(label: Text('Trạng Thái')),
            DataColumn(label: Text('Tổng Tiền')),
          ],
          rows: List.generate(
            5,
            (index) => DataRow(
              cells: [
                DataCell(Text('#ORD-00$index')),
                const DataCell(Text('Nguyễn Văn A')),
                const DataCell(
                  Chip(
                    label: Text('Đang xử lý', style: TextStyle(fontSize: 12)),
                    backgroundColor: Color(0xFFFFF9C4),
                  ),
                ),
                const DataCell(Text('1,200,000đ')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
