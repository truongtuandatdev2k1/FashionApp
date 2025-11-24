import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/admin/features/dashboard/presentation/screens/stats_screen.dart';
import 'package:ui_mobile_fashion_app/admin/presentation/splash/admin_splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const AdminSplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();  // Sử dụng AdminLoginScreen nếu bạn rename
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const StatsScreen();  // Màn chính: dashboard thống kê
        },
      ),
      // Thêm route khác sau: ví dụ GoRoute(path: '/product-crud', builder: ...);
    ],
  );
}