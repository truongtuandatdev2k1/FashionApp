// lib/main_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ← THÊM: để load .env.dev

import 'core/config/build_config.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart'; // ← THÊM: để gọi ApiConfig.init()
import 'admin/routes/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load file .env.dev trước tiên (cần cho AppConfig.baseUrl)
  await dotenv.load(fileName: ".env.dev");

  // 2. Init ApiConfig → tạo Dio với baseUrl từ .env và thêm TokenInterceptor
  await ApiConfig.init();

  // 3. Sau đó mới setup DI (đăng ký Dio, ApiClient, v.v.)
  await setupDependencies();

  // 4. Giữ nguyên phần orientation nếu là admin flavor
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
