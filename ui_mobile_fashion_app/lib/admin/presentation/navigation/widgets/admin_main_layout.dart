// file: lib/admin/presentation/navigation/widgets/admin_main_layout.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/admin/presentation/navigation/sidebar_wrapper.dart';

class AdminMainLayout extends StatelessWidget {
  final Widget child;

  const AdminMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4), // Màu nền tổng thể theo yêu cầu
      drawer:
          isMobile ? const Drawer(child: AdminSidebar(isMobile: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile, context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isMobile, BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white, // Topbar trắng
      // Không có BoxShadow hay Border để đảm bảo thiết kế phẳng
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (!isMobile)
            // Tiêu đề hoặc Breadcrumb có thể để ở đây
            const Text(
              "Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFF2F3F4),
            child: Icon(Icons.person, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
