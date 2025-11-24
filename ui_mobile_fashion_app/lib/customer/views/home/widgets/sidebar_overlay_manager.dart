// lib/customer/views/home/widgets/sidebar_overlay_manager.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SidebarOverlayManager extends StatefulWidget {
  final Widget child;

  const SidebarOverlayManager({super.key, required this.child});

  @override
  State<SidebarOverlayManager> createState() => _SidebarOverlayManagerState();

  static void open(BuildContext context) {
    context.findAncestorStateOfType<_SidebarOverlayManagerState>()?._openSidebar();
  }

  static void close(BuildContext context) {
    context.findAncestorStateOfType<_SidebarOverlayManagerState>()?._closeSidebar();
  }
}

class _SidebarOverlayManagerState extends State<SidebarOverlayManager>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  void _openSidebar() => _controller.forward();
  void _closeSidebar() => _controller.reverse();

  void _onMenuItemTap(String title) {
    print('Đã chọn: $title');
    _closeSidebar();

    if (title == 'Danh mục') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mở trang Danh mục')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _buildSidebarOverlay(),
      ],
    );
  }

  Widget _buildSidebarOverlay() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final slide = -280.0 * (1 - _animation.value);
        final opacity = 0.6 * _animation.value;

        return Stack(
          children: [
            // LỚP MỜ TOÀN MÀN HÌNH
            if (_animation.value > 0)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeSidebar,
                  child: Container(color: Colors.black.withOpacity(opacity)),
                ),
              ),

            // SIDEBAR
            Positioned(
              left: slide,
              top: 0,
              bottom: 0,
              width: 280,
              child: SafeArea(
                child: Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _menuItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            return ListTile(
                              leading: Icon(item['icon'], color: Colors.black87, size: 22),
                              title: Text(
                                item['title'],
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                              onTap: () => _onMenuItemTap(item['title']),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // NÚT X – SÁT SIDEBAR, KHÔNG CÓ TRÒN XÁM
            if (_animation.value > 0)
              Positioned(
                top: 32,
                left: 280 + 8, // Sát sidebar
                child: GestureDetector(
                  onTap: _closeSidebar,
                  child: const Icon(
                    LucideIcons.chevronsLeft, // ĐÃ ĐỔI
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // GIỮ NGUYÊN DANH SÁCH ICON – KHÔNG SỬA
  static const List<Map<String, dynamic>> _menuItems = [
    {'icon': LucideIcons.grid2x2, 'title': 'Danh mục'},
    {'icon': LucideIcons.trendingUp, 'title': 'Xu hướng'},
    {'icon': LucideIcons.tag, 'title': 'Khuyến mãi'},
    {'icon': LucideIcons.gift, 'title': 'Ưu đãi cá nhân'},
    {'icon': LucideIcons.heart, 'title': 'Yêu thích'},
    {'icon': LucideIcons.clock, 'title': 'Đã xem gần đây'},
    {'icon': LucideIcons.handHelping, 'title': 'Hỗ trợ'},
    {'icon': LucideIcons.settings, 'title': 'Cài đặt'},
  ];
}