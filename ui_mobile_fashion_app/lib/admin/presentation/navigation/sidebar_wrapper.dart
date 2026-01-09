// file: lib/admin/presentation/navigation/sidebar_wrapper.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';
import 'sidebar_config.dart';

class AdminSidebar extends StatelessWidget {
  final bool isMobile;
  const AdminSidebar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.toString();

    return Container(
      width: isMobile ? double.infinity : 260,
      color: Colors.white, // Nền trắng theo yêu cầu
      child: Column(
        children: [
          // --- PHẦN HEADER CHỈ HIỂN THỊ LOGO CĂN GIỮA ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            width:
                double
                    .infinity, // Đảm bảo container chiếm hết chiều rộng sidebar
            alignment: Alignment.center, // Căn giữa logo theo cả hai chiều
            child: Assets.logoFas.image(
              height: 30, // Bạn có thể điều chỉnh kích thước lớn hơn nếu muốn
              fit: BoxFit.contain,
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: SidebarConfig.items.length,
              itemBuilder: (context, index) {
                final item = SidebarConfig.items[index];
                final isSelected = currentLocation.startsWith(item.route);

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    // Item được chọn có nền xám nhẹ, bo góc, không viền
                    color:
                        isSelected
                            ? const Color(0xFFF2F3F4)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      // Selected: Đen, Unselected: Xám
                      color: isSelected ? Colors.black : Colors.grey,
                      size: 22,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        // Selected: Đậm + Đen, Unselected: Xám
                        color: isSelected ? Colors.black : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      context.go(item.route);
                      if (isMobile) Navigator.pop(context);
                    },
                    // Bỏ hiệu ứng ripple mặc định để "phẳng" hơn
                    hoverColor: Colors.transparent,
                  ),
                );
              },
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
                size: 20,
              ),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
              onTap: () => context.go('/login'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }
}
