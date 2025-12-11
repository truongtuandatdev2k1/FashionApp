// lib/admin/routes/admin_router.dart
import 'package:go_router/go_router.dart';

import 'package:ui_mobile_fashion_app/admin/presentation/splash/admin_splash_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/auth/presentation/screens/login_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/dashboard/presentation/screens/stats_screen.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // thêm dòng này để tránh lỗi mặc định
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminSplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder:
            (context, state) =>
                const LoginScreen(), // nếu class tên là AdminLoginScreen thì sửa thành AdminLoginScreen()
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const StatsScreen(),
      ),
    ],
  );
}
