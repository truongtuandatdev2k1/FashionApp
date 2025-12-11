// lib/core/router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/complete_profile_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/register_screen.dart';
// ***************************************************************
// 1. CẬP NHẬT IMPORT: Trỏ đến file Navigation Shell MỚI
import 'package:ui_mobile_fashion_app/customer/views/navigation_shell/customer_navigation_shell.dart';
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
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          // ***************************************************************
          // 2. CẬP NHẬT WIDGET: Trỏ '/home' đến CustomerNavigationShell mới
          return const CustomerNavigationShell();
          // ***************************************************************
        },
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressListScreen(),
      ),
      // Thêm route khác sau này
    ],
  );
}
