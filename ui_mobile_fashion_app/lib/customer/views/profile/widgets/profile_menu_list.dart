// lib/customer/views/profile/widgets/profile_menu_list.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/logic/auth/auth_api.dart';

const Color kPrimaryColor = Colors.black;

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          text: "Tài Khoản Của Tôi",
          iconData: LucideIcons.user,
          onTap: () {},
        ),
        ProfileMenuItem(
          text: "Thông Báo",
          iconData: LucideIcons.bell,
          onTap: () {},
        ),
        ProfileMenuItem(
          text: "Cài Đặt",
          iconData: LucideIcons.settings,
          onTap: () {},
        ),
        ProfileMenuItem(
          text: "Trung Tâm Trợ Giúp",
          iconData: LucideIcons.handHelping,
          onTap: () {},
        ),
        ProfileMenuItem(
          text: "Đăng Xuất",
          iconData: LucideIcons.logOut,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CustomerAuthApi.logout(context);
    }
  }
}

// Widget con cho từng menu
class ProfileMenuItem extends StatelessWidget {
  final String text;
  final IconData iconData;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.text,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryColor,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            // ICON: Luôn màu đen
            Icon(iconData, color: kPrimaryColor, size: 22),

            const SizedBox(width: 20),

            // TEXT: Luôn màu đen, không đậm
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.normal, // Không bold
                ),
              ),
            ),

            // MŨI TÊN: Luôn màu đen
            const Icon(
              Icons.arrow_forward_ios,
              color: kPrimaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}