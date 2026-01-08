// lib/customer/views/navigation_shell/customer_navigation_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/sidebar_overlay_manager.dart';

class CustomerNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerNavigationShell({super.key, required this.navigationShell});

  static const List<IconData> _icons = [
    LucideIcons.house,
    LucideIcons.heart,
    LucideIcons.shoppingBag,
    LucideIcons.user,
  ];

  // Sửa hàm _onTap trong file customer_navigation_shell.dart
  void _onTap(BuildContext context, int index) {
    // Nếu nhấn vào tab đang đứng (ví dụ tab Cart),
    // ta có thể thực hiện logic đặc biệt, nhưng GoRouter mặc định sẽ không làm gì.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarOverlayManager(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xff99A1AF),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: List.generate(4, (index) {
            final isSelected = index == navigationShell.currentIndex;
            final size = isSelected ? 26.0 : 22.0;
            return BottomNavigationBarItem(
              icon: Icon(_icons[index], size: size),
              label: '',
            );
          }),
        ),
      ),
    );
  }
}
