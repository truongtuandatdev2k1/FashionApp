// lib/core/router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/cart/cart_api.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/complete_profile_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/register_screen.dart';
// ***************************************************************
// 1. CẬP NHẬT IMPORT: Trỏ đến file Navigation Shell MỚI
import 'package:ui_mobile_fashion_app/customer/views/navigation_shell/customer_navigation_shell.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/my_order_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/order_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/widgets/order_failure_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/widgets/order_success_screen.dart';
// ***************************************************************
import 'package:ui_mobile_fashion_app/customer/views/splash/customer_splash_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/login_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/views/address_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const CustomerSplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/order',
        builder: (context, state) {
          final cart = state.extra;
          if (cart is CartResponse) {
            return OrderScreen(cart: cart);
          }
          // Nếu không có dữ liệu giỏ hàng, chuyển hướng về trang chủ hoặc giỏ hàng
          return const CustomerNavigationShell();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          // ***************************************************************
          // 2. CẬP NHẬT WIDGET: Trỏ '/home' đến CustomerNavigationShell mới
          return const CustomerNavigationShell();
          // ***************************************************************
        },
      ),
      // Route Đặt hàng thành công
      GoRoute(
        path: '/order-success',
        builder: (context, state) => const OrderSuccessScreen(),
      ),

      // Route Lỗi đặt hàng (nhận tham số lỗi)
      GoRoute(
        path: '/order-failure',
        builder: (context, state) {
          final error = state.extra as String? ?? 'Lỗi không xác định';
          return OrderFailureScreen(errorMessage: error);
        },
      ),
      // Route Đơn hàng của tôi
      GoRoute(
        path: '/my-orders',
        builder: (context, state) => const MyOrderScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressListScreen(),
      ),
      // THÊM ROUTE PROFILE: Trỏ '/profile' đến CustomerNavigationShell
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const CustomerNavigationShell();
        },
      ),
      // Thêm route khác sau này
    ],
  );
}
