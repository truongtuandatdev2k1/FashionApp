// lib/customer/views/home/widgets/utility_access_bar.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget hiển thị thanh 4 mục truy cập tiện ích (có tiêu đề)
class UtilityAccessBar extends StatelessWidget {
  const UtilityAccessBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12), // top: 20dp
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIÊU ĐỀ
          const Text(
            'Truy cập tiện ích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          // KHOẢNG CÁCH GIỮA TIÊU ĐỀ & 4 MỤC
          const SizedBox(height: 18),

          // 4 MỤC TIỆN ÍCH
          LayoutBuilder(
            builder: (context, constraints) {
              // 4 mục, trừ 2×16dp margin → chia đều
              final double itemWidth = (constraints.maxWidth - 32) / 4;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildItem(LucideIcons.shirt, 'Sản phẩm', itemWidth),
                  _buildItem(LucideIcons.percent, 'Khuyến mãi', itemWidth),
                  _buildItem(LucideIcons.truck, 'Vận chuyển', itemWidth),
                  _buildItem(LucideIcons.headphones, 'Hỗ trợ', itemWidth),
                  // ĐÃ BỎ: Quà tặng
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, double width) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Nền đậm
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
    );
  }
}