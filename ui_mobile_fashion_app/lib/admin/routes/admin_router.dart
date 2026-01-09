// file: lib/admin/routes/admin_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/auth/presentation/screens/login_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/order/presentation/screens/order_list_screen.dart';
import 'package:ui_mobile_fashion_app/admin/presentation/navigation/widgets/admin_main_layout.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/screens/product_list_screen.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/orders', // Mặc định vào dashboard
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AdminMainLayout(child: child);
        },
        routes: [
          // // 1. Tổng Quan
          // GoRoute(
          //   path: '/dashboard',
          //   builder: (context, state) => const StatsScreen(),
          // ),
          // 2. Sản Phẩm (Đã có logic)
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListScreen(),
          ),
          // 3. Đơn Hàng
          // Trong AdminRouter.router:
          GoRoute(
            path: '/orders',
            builder:
                (context, state) =>
                    const OrderListScreen(), // Thay _SimplePage bằng OrderListScreen
          ),
          // 4. Kho Hàng
          GoRoute(
            path: '/inventory',
            builder:
                (context, state) =>
                    const _SimplePage(title: 'Quản Lý Kho Hàng'),
          ),
          // 5. Khách Hàng
          GoRoute(
            path: '/customers',
            builder:
                (context, state) =>
                    const _SimplePage(title: 'Danh Sách Khách Hàng'),
          ),
          // 6. Marketing
          GoRoute(
            path: '/marketing',
            builder:
                (context, state) =>
                    const _SimplePage(title: 'Marketing & Voucher'),
          ),
          // 7. Báo Cáo
          GoRoute(
            path: '/analytics',
            builder:
                (context, state) =>
                    const _SimplePage(title: 'Báo Cáo Thống Kê'),
          ),
          // 8. Cấu Hình
          GoRoute(
            path: '/settings',
            builder:
                (context, state) =>
                    const _SimplePage(title: 'Cấu Hình Hệ Thống'),
          ),
        ],
      ),
    ],
  );
}

// Widget đơn giản dùng chung cho các trang chưa implement
class _SimplePage extends StatelessWidget {
  final String title;
  const _SimplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F3F4), // Đảm bảo nền khớp layout
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Không box shadow, không border theo yêu cầu
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nội dung đang được phát triển',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
