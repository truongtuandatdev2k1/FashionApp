import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_mobile_fashion_app/main_customer.dart';  // Fix: Import main_customer.dart thay main.dart
import 'package:ui_mobile_fashion_app/customer/views/splash/customer_splash_screen.dart';  // Import splash để test

void main() {
  testWidgets('Customer Splash Screen displays welcome text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(  // Wrap trong MaterialApp để test widget độc lập
      home: CustomerSplashScreen(),
    ));

    // Verify that the welcome text is displayed.
    expect(find.text('Welcome to Customer App'), findsOneWidget);  // Fix: Test text thực tế
    expect(find.text('Mua Sắm Dễ Dàng!'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);  // Test icon

    // Optional: Test no other text (e.g., no admin text)
    expect(find.text('Quản Lý Thông Minh!'), findsNothing);
  });
}