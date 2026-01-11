// lib/admin/presentation/navigation/sidebar_config.dart
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
    SidebarItemModel(
      title: 'Đơn Hàng',
      icon: Icons.shopping_cart_outlined,
      route: '/orders',
    ),
    SidebarItemModel( // bỏ cái này đi
      title: 'Sản Phẩm',
      icon: Icons.checkroom_outlined,
      route: '/products',
    ),
    // Kiểm tra kỹ chuỗi '/brands'
    SidebarItemModel(
      title: 'Nhãn Hàng',
      icon: Icons.auto_awesome_outlined,
      route: '/brands', // Đảm bảo không có dấu cách: ' /brands' hoặc '/brands '
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