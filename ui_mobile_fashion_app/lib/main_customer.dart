// lib/main_customer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart';
import 'core/router.dart';
import 'customer/logic/profile/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // BƯỚC 1: Load .env.dev (bắt buộc trước khi dùng)
  await dotenv.load(fileName: ".env.dev");

  // BƯỚC 2: Init DI + API
  await setupDependencies();
  await ApiConfig.init();

  // BƯỚC 3: Chạy app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp.router(
        title: 'Dat Fashion App',
        theme: ThemeData(fontFamily: 'Roboto'),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}