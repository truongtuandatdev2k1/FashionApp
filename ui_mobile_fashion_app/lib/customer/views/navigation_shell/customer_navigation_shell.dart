// lib/customer/views/navigation_shell/customer_navigation_shell.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/sidebar_overlay_manager.dart'; // Import mới

import 'package:ui_mobile_fashion_app/customer/views/cart/views/cart_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/views/home_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/profile/views/profile_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/saved/views/saved_screen.dart';

class CustomerNavigationShell extends StatefulWidget {
  const CustomerNavigationShell({super.key});

  @override
  State<CustomerNavigationShell> createState() =>
      _CustomerNavigationShellState();
}

class _CustomerNavigationShellState extends State<CustomerNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SavedScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<IconData> _navIconData = const [
    LucideIcons.house,
    LucideIcons.heart,
    LucideIcons.shoppingBag,
    LucideIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navBarItems = List.generate(
      _pages.length,
      (index) {
        final isSelected = index == _selectedIndex;
        final size = isSelected ? 26.0 : 22.0;
        return BottomNavigationBarItem(
          icon: Icon(_navIconData[index], size: size),
          label: '',
        );
      },
    );

    return SidebarOverlayManager(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xff99A1AF),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
          items: navBarItems,
        ),
      ),
    );
  }
}
