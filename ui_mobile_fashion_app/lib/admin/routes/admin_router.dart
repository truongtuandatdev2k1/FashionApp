import 'package:flutter/material.dart'; // THÊM DÒNG NÀY ĐỂ HẾT LỖI SCAFFOLD, CENTER...
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/auth/presentation/screens/login_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/dashboard/presentation/screens/stats_screen.dart';
import 'package:ui_mobile_fashion_app/admin/presentation/navigation/widgets/admin_main_layout.dart'; // Import file product list screen (đường dẫn dựa trên cấu trúc folder của bạn)
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/screens/product_list_screen.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      ShellRoute(
        builder: (context, state, child) {
          return AdminMainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListScreen(),
          ),
          // Đối với các trang chưa làm, bạn có thể tạo một Scaffold nhanh như thế này:
          GoRoute(
            path: '/orders',
            builder:
                (context, state) => const Scaffold(
                  body: Center(child: Text('Quản lý đơn hàng')),
                ),
          ),
          GoRoute(
            path: '/customers',
            builder:
                (context, state) => const Scaffold(
                  body: Center(child: Text('Quản lý khách hàng')),
                ),
          ),
        ],
      ),
    ],
  );
}
