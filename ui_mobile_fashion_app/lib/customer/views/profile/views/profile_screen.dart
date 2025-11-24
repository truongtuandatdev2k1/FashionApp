// lib/customer/views/profile/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_mobile_fashion_app/customer/logic/profile/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProfileController>(
        builder: (context, controller, child) {
          // 1. ĐANG LOADING → HIỆN LOADING TOÀN TRANG
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2.5,
              ),
            );
          }

          // 2. CÓ LỖI → HIỆN THÔNG BÁO
          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchProfile(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // 3. ĐÃ CÓ DỮ LIỆU → HIỆN NỘI DUNG
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                ProfileHeader(userData: controller.userData),
                const ProfileMenuList(),
              ],
            ),
          );
        },
      ),
    );
  }
}