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
      // Drawer dùng chung cho Mobile
      drawer:
          isMobile ? const Drawer(child: AdminSidebar(isMobile: true)) : null,
      body: Row(
        children: [
          // Sidebar cố định cho Web/Desktop
          if (!isMobile) const AdminSidebar(),

          // Nội dung chính
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile, context),
                // Phần nội dung thay đổi theo Route
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
}
