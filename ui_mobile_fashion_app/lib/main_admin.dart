// lib/main_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/build_config.dart';
import 'core/di/locator.dart';          // giữ nguyên
import 'admin/routes/admin_router.dart'; // bạn đã đổi thành routes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SỬA DÒNG NÀY: hàm thực tế là setupDependencies(), không phải setupLocator()
  await setupDependencies();   // ← ĐÚNG RỒI

  if (BuildConfig.flavor == 'admin') {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Admin App',
      theme: ThemeData(primarySwatch: Colors.green),
      routerConfig: AdminRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}