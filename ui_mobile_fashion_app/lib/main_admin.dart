import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart';
import 'admin/routes/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Chỉ ghi tên file, không ghi đường dẫn assets/
    await dotenv.load(fileName: ".env.dev");
    debugPrint("Env loaded successfully");
  } catch (e) {
    debugPrint("Env load error: $e");
  }

  // Khởi tạo Dio sau khi đã có baseUrl từ env
  await ApiConfig.init();

  // Đăng ký các service vào GetIt
  await setupDependencies();

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
