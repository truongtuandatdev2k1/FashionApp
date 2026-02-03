// file: lib/admin/routes/admin_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/auth/presentation/screens/login_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/brands/presentation/screens/brand_list_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/brands/presentation/screens/brand_product_list_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/order/presentation/screens/order_list_screen.dart';
import 'package:ui_mobile_fashion_app/admin/presentation/navigation/widgets/admin_main_layout.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/screens/product_list_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/screens/create_product_page_1.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/screens/create_product_page_2.dart';
import 'package:ui_mobile_fashion_app/core/network/token_manager.dart';
import 'package:ui_mobile_fashion_app/core/network/user_manager.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/orders',

    // ===== REDIRECT LOGIC - KIỂM TRA TOKEN =====
    redirect: (context, state) async {
      final isLoggedIn = await TokenManager.isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/orders';

      if (isLoggedIn) {
        final user = await UserManager.getUser();
        if (user != null && user['role'] != 'shop') {
          await TokenManager.clearTokens();
          await UserManager.clearUser();
          return '/login';
        }
      }
      return null;
    },

    routes: [
      // Route Login (public)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Routes yêu cầu authentication (protected)
      ShellRoute(
        builder: (context, state, child) => AdminMainLayout(child: child),
        routes: [
          GoRoute(path: '/products', builder: (context, state) => const ProductListScreen()),
          GoRoute(path: '/orders', builder: (context, state) => const OrderListScreen()),

          // ✅ CHỈ GIỮ 1 ROUTE /brands CÓ SUB-ROUTES (xóa duplicate)
          GoRoute(
            path: '/brands',
            builder: (context, state) => const BrandListScreen(),
            routes: [
              // Brand products list
              GoRoute(
                path: 'products/:id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  final name = state.uri.queryParameters['name'] ?? '';
                  final logo = state.uri.queryParameters['logo'] ?? '';
                  return BrandProductListScreen(brandId: id, brandName: name, logoUrl: logo);
                },
              ),
              // ✅ NEW: Create Product Step 1
              GoRoute(
                path: 'products/create/step1',
                builder: (context, state) {
                  final brandId = int.tryParse(state.uri.queryParameters['brandId'] ?? '0') ?? 0;
                  final brandName = Uri.decodeComponent(state.uri.queryParameters['brandName'] ?? '');
                  return CreateProductPage1(brandId: brandId, brandName: brandName);
                },
              ),
              // ✅ FIXED: Create Product Step 2 - ĐỌC productId từ query params
              GoRoute(
                path: 'products/create/step2',
                builder: (context, state) {
                  final brandId = int.tryParse(state.uri.queryParameters['brandId'] ?? '0') ?? 0;
                  final brandName = Uri.decodeComponent(state.uri.queryParameters['brandName'] ?? '');
                  final productId = int.tryParse(state.uri.queryParameters['productId'] ?? '10') ?? 10; // ✅ THÊM ĐÂY
                  return CreateProductPage2(
                    brandId: brandId,
                    brandName: brandName,
                    productId: productId, // ✅ TRUYỀN productId
                  );
                },
              ),
            ],
          ),

          // Các route khác giữ nguyên
          GoRoute(path: '/customers', builder: (context, state) => const _SimplePage(title: 'Danh Sách Khách Hàng')),
          GoRoute(path: '/marketing', builder: (context, state) => const _SimplePage(title: 'Marketing & Voucher')),
          GoRoute(path: '/analytics', builder: (context, state) => const _SimplePage(title: 'Báo Cáo Thống Kê')),
          GoRoute(path: '/settings', builder: (context, state) => const _SimplePage(title: 'Cấu Hình Hệ Thống')),
        ],
      ),
    ],
  );
}

// Widget đơn giản dùng chung
class _SimplePage extends StatelessWidget {
  final String title;
  const _SimplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F3F4),
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              const Text('Nội dung đang được phát triển', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}