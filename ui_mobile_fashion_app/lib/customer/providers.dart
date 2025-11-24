// lib/customer/providers.dart
import 'package:provider/provider.dart';
import 'logic/profile/profile_controller.dart';
// Thêm provider khác ở đây

List<ChangeNotifierProvider> get customerProviders => [
  ChangeNotifierProvider(create: (_) => ProfileController()),
  // ChangeNotifierProvider(create: (_) => CartController()),
];