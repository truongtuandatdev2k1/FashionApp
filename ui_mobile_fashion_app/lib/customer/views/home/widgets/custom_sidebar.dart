// // lib/customer/views/home/widgets/custom_sidebar.dart
//
// import 'package:flutter/material.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart';
//
// class CustomSidebar extends StatelessWidget {
//   final Animation<double> animation;
//   final VoidCallback onClose;
//   final Function(String) onItemTap;
//
//   const CustomSidebar({
//     super.key,
//     required this.animation,
//     required this.onClose,
//     required this.onItemTap,
//   });
//
//   static const List<Map<String, dynamic>> _menuItems = [
//     {'icon': LucideIcons.grid2x2, 'title': 'Danh mục'},
//     {'icon': LucideIcons.trendingUp, 'title': 'Xu hướng'},
//     {'icon': LucideIcons.tag, 'title': 'Khuyến mãi'},
//     {'icon': LucideIcons.gift, 'title': 'Ưu đãi cá nhân'},
//     {'icon': LucideIcons.heart, 'title': 'Yêu thích'},
//     {'icon': LucideIcons.clock, 'title': 'Đã xem gần đây'},
//     {'icon': LucideIcons.handHelping, 'title': 'Hỗ trợ'},
//     {'icon': LucideIcons.settings, 'title': 'Cài đặt'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) {
//         final slide = -280.0 * (1 - animation.value);
//         final opacity = 0.6 * animation.value;
//
//         return Stack(
//           children: [
//             // LỚP MỜ TOÀN MÀN HÌNH
//             if (animation.value > 0)
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTap: onClose,
//                   child: Container(color: Colors.black.withOpacity(opacity)),
//                 ),
//               ),
//
//             // SIDEBAR: CHE TOÀN BỘ, BAO GỒM APPBAR & BOTTOM NAV
//             Positioned(
//               left: slide,
//               top: 0,
//               bottom: 0,
//               width: 280,
//               child: SafeArea( // Đảm bảo không bị notch che
//                 child: Material(
//                   color: Colors.white,
//                   elevation: 0,
//                   child: Column(
//                     children: [
//                       // SÁT TRÊN, KHÔNG HEADER
//                       Expanded(
//                         child: ListView.separated(
//                           padding: EdgeInsets.zero,
//                           itemCount: _menuItems.length,
//                           separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
//                           itemBuilder: (context, index) {
//                             final item = _menuItems[index];
//                             return _buildMenuItem(
//                               icon: item['icon'],
//                               title: item['title'],
//                               onTap: () {
//                                 onItemTap(item['title']);
//                                 onClose();
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.black87, size: 22),
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       dense: true,
//     );
//   }
// }