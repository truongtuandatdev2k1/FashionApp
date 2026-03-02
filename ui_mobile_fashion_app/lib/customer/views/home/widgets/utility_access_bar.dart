// lib/customer/views/home/widgets/utility_access_bar.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/core/utils/extensions.dart'; // ← thêm import này

/// Widget hiển thị thanh 4 mục truy cập tiện ích (có tiêu đề)
class UtilityAccessBar extends StatelessWidget {
  const UtilityAccessBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Truy cập tiện ích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - 32) / 4;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildItem(
                    context,
                    LucideIcons.box,
                    'Đơn hàng',
                    itemWidth,
                    onTap: () => context.go('/profile/my-orders'), // ← thêm hành động
                  ),
                  _buildItem(context, LucideIcons.percent, 'Khuyến mãi', itemWidth),
                  _buildItem(context, LucideIcons.truck, 'Vận chuyển', itemWidth),
                  _buildItem(context, LucideIcons.headphones, 'Hỗ trợ', itemWidth),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context,
      IconData icon,
      String label,
      double width, {
        VoidCallback? onTap,          // ← thêm tham số onTap (optional)
      }) {
    return GestureDetector(        // ← bọc bằng GestureDetector để click được
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}