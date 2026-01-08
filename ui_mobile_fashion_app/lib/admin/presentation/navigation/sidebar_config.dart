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
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    SidebarItemModel(
      title: 'Quản Lý Sản Phẩm',
      icon: Icons.inventory_2,
      route: '/products',
    ),
    SidebarItemModel(
      title: 'Quản Lý Đơn Hàng',
      icon: Icons.shopping_cart,
      route: '/orders',
    ),
    SidebarItemModel(
      title: 'Khách Hàng',
      icon: Icons.people,
      route: '/customers',
    ),
  ];
}
