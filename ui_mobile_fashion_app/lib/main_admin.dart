import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_mobile_fashion_app/core/config/build_config.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart';
import 'admin/routes/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.init(); // Bây giờ nó dùng link cứng nên sẽ không lỗi
  await setupDependencies();

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
