// lib/admin/routes/admin_router.dart
import 'package:go_router/go_router.dart';

// import 'package:ui_mobile_fashion_app/admin/presentation/splash/admin_splash_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/auth/presentation/screens/login_screen.dart';
import 'package:ui_mobile_fashion_app/admin/features/dashboard/presentation/screens/stats_screen.dart';

// lib/admin/routes/admin_router.dart
class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Thay đổi ở đây để vào thẳng Login
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const StatsScreen(),
      ),
    ],
  );
}
