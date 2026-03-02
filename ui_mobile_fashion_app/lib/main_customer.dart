// lib/main_customer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/flavor_config.dart';
import 'core/di/locator.dart';
import 'core/network/api_config.dart';
import 'customer/router/customer_router.dart';
import 'customer/logic/profile/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo trực tiếp thay vì load từ file
  await FlavorConfig.init(flavor: Flavor.dev);

  await setupDependencies();
  await ApiConfig.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProfileController())],
      child: MaterialApp.router(
        title: 'Dat Fashion App',
        theme: ThemeData(fontFamily: 'Roboto'),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
