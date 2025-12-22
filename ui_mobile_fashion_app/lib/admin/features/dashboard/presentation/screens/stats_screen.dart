import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để hỗ trợ Responsive cơ bản
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar cố định (Chỉ hiện khi không phải Mobile)
          if (!isMobile) _buildSidebar(context),

          // 2. Nội dung chính bên phải
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile, context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng Quan Hệ Thống',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Hàng các thẻ thống kê
                        _buildStatsGrid(screenWidth),

                        const SizedBox(height: 32),
                        const Text(
                          'Hoạt động gần đây',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecentActivityTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Hiện Drawer nếu là màn hình nhỏ (Mobile/Tablet dọc)
      drawer: isMobile ? Drawer(child: _buildSidebarContent(context)) : null,
    );
  }

  // Sidebar cho bản Web
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1A1F36), // Màu tối sang trọng cho Web Admin
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      children: [
        const UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Color(0xFF2E3552)),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
          accountName: Text('Admin Manager'),
          accountEmail: Text('admin@fashionapp.com'),
        ),
        _buildSidebarItem(Icons.dashboard, 'Dashboard', isSelected: true),
        _buildSidebarItem(Icons.inventory_2, 'Quản Lý Sản Phẩm'),
        _buildSidebarItem(Icons.shopping_cart, 'Quản Lý Đơn Hàng'),
        _buildSidebarItem(Icons.people, 'Khách Hàng'),
        const Spacer(),
        _buildSidebarItem(Icons.logout, 'Đăng xuất', color: Colors.redAccent),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title, {
    bool isSelected = false,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (isSelected ? Colors.green : Colors.grey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isSelected ? Colors.green : Colors.white70),
        ),
      ),
      onTap: () {},
      selected: isSelected,
      hoverColor: Colors.white12,
    );
  }

  // Thanh công cụ phía trên
  Widget _buildTopBar(bool isMobile, BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Text(
            'Fashion Admin Panel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none, color: Colors.grey),
          const SizedBox(width: 20),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
        ],
      ),
    );
  }

  // Lưới các thẻ thống kê
  Widget _buildStatsGrid(double width) {
    int crossAxisCount = width > 1200 ? 4 : (width > 800 ? 2 : 1);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: 2.5,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bảng placeholder
  Widget _buildRecentActivityTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DataTable(
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
                Chip(label: Text('Đang xử lý'), backgroundColor: Colors.yellow),
              ),
              const DataCell(Text('1,200,000đ')),
            ],
          ),
        ),
      ),
    );
  }
}
