import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'sidebar_config.dart';

class AdminSidebar extends StatelessWidget {
  final bool isMobile;
  const AdminSidebar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    // Lấy route hiện tại để xác định item nào đang được chọn
    final String currentLocation = GoRouterState.of(context).uri.toString();

    return Container(
      width: isMobile ? double.infinity : 260,
      color: const Color(0xFF1A1F36),
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2E3552)),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            accountName: Text('Admin Manager'),
            accountEmail: Text('admin@fashionapp.com'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: SidebarConfig.items.length,
              itemBuilder: (context, index) {
                final item = SidebarConfig.items[index];
                final isSelected = currentLocation.startsWith(item.route);

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? Colors.green : Colors.white70,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    context.go(item.route);
                    if (isMobile)
                      Navigator.pop(context); // Đóng drawer nếu là mobile
                  },
                );
              },
            ),
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () => context.go('/login'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
