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
          Expanded(child: Column(children: [Expanded(child: child)])),
        ],
      ),
    );
  }
}
