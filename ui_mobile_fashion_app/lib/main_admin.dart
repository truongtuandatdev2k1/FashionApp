import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart';
import 'admin/routes/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load file cấu hình từ thư mục assets
  try {
    await dotenv.load(fileName: "assets/.env.dev");
  } catch (e) {
    debugPrint("Lỗi không thể load env: $e");
  }

  // 2. Khởi tạo cấu hình API sau khi đã load xong env
  await ApiConfig.init();

  // 3. Setup Dependency Injection (GetIt)
  await setupDependencies();

  // 4. Cấu hình giao diện
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
