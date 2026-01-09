// lib/core/router.dart
// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/customer/logic/cart/cart_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';

import 'package:ui_mobile_fashion_app/customer/views/auth/complete_profile_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/register_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/navigation_shell/customer_navigation_shell.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/my_order_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/order_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/widgets/order_failure_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/order/widgets/order_success_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/splash/customer_splash_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/auth/login_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/views/address_list_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/views/address_form_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/views/home_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/saved/views/saved_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/cart/views/cart_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/profile/views/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const CustomerSplashScreen(),
      ),

      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),

      // Order Routes (Nằm ngoài Shell để ẩn Bottom Navigation Bar)
      GoRoute(
        path: '/order',
        redirect: (context, state) {
          // Kiểm tra nếu extra không phải CartResponse thì quay về Home
          // Điều này ngăn lỗi khi người dùng reload trang hoặc truy cập trực tiếp
          if (state.extra is! CartResponse) {
            return '/home';
          }
          return null;
        },
        builder: (context, state) {
          final cart = state.extra as CartResponse;
          return OrderScreen(cart: cart);
        },
      ),
      GoRoute(
        path: '/order-success',
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/order-failure',
        builder: (context, state) {
          final error = state.extra as String? ?? 'Lỗi không xác định';
          return OrderFailureScreen(errorMessage: error);
        },
      ),

      // ========== SHELL ROUTE CHÍNH - 4 TABS ==========
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Truyền đúng navigationShell vào để hiển thị Bottom Bar
          return CustomerNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Saved
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          // Branch 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          // Branch 3: Profile + các màn hình con
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  // My Orders
                  GoRoute(
                    path: 'my-orders',
                    builder: (context, state) => const MyOrderScreen(),
                  ),
                  // Address Management
                  GoRoute(
                    path: 'addresses',
                    builder: (context, state) => const AddressListScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const AddressFormScreen(),
                      ),
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final address = state.extra as Address;
                          return AddressFormScreen(address: address);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
