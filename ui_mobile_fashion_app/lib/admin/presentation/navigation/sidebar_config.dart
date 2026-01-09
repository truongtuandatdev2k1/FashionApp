// file: lib/admin/presentation/navigation/sidebar_config.dart
import 'package:flutter/material.dart';

class SidebarItemModel {
  final String title;
  final IconData icon;
  final String route;

  const SidebarItemModel({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class SidebarConfig {
  static const List<SidebarItemModel> items = [
    // SidebarItemModel(
    //   title: 'Tổng Quan',
    //   icon: Icons.dashboard_outlined,
    //   route: '/dashboard',
    // ),
    SidebarItemModel(
      title: 'Đơn Hàng',
      icon: Icons.shopping_cart_outlined,
      route: '/orders',
    ),
    SidebarItemModel(
      title: 'Sản Phẩm',
      icon: Icons.checkroom_outlined, // Icon quần áo
      route: '/products',
    ),
    SidebarItemModel(
      title: 'Kho Hàng',
      icon: Icons.warehouse_outlined,
      route: '/inventory',
    ),
    SidebarItemModel(
      title: 'Khách Hàng',
      icon: Icons.people_outline,
      route: '/customers',
    ),
    SidebarItemModel(
      title: 'Marketing & Voucher',
      icon: Icons.local_offer_outlined,
      route: '/marketing',
    ),
    SidebarItemModel(
      title: 'Báo Cáo',
      icon: Icons.bar_chart_outlined,
      route: '/analytics',
    ),
    SidebarItemModel(
      title: 'Cấu Hình',
      icon: Icons.settings_outlined,
      route: '/settings',
    ),
  ];
}
