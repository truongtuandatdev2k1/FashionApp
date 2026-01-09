// lib/main_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/build_config.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart';
import 'admin/routes/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. CẬP NHẬT: Load file từ đường dẫn assets/ để khớp với pubspec.yaml và script build
  try {
    await dotenv.load(fileName: "assets/.env.dev");
  } catch (e) {
    // Fallback nếu không load được file (hữu ích để debug trên web)
    debugPrint("Lỗi load env: $e");
  }

  // 2. Init ApiConfig → sử dụng các biến đã load từ dotenv
  await ApiConfig.init();

  // 3. Setup Dependency Injection
  await setupDependencies();

  // 4. Giữ nguyên định hướng màn hình cho Admin
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
