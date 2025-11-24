// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'core/config/build_config.dart';
// import 'core/di/locator.dart';
// import 'admin/navigation/admin_router.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Setup dependency injection
//   await setupLocator();
//
//   if (BuildConfig.flavor == 'admin') {
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   }
//
//   runApp(const AdminApp());
// }
//
// class AdminApp extends StatelessWidget {
//   const AdminApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Admin App',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       routerConfig: AdminRouter.router,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }