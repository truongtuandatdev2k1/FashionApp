// lib/customer/views/product/widgets/product_detail/body/price_sold.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart'; // Dùng Lucide để icon star đẹp hơn

class PriceAndSold extends StatelessWidget {
  final String title;
  final double currentPrice;
  final double oldPrice;
  final double rating;        // THÊM LẠI
  final int reviewCount;      // Số lượt đánh giá (ví dụ: 1700)
  final int soldCount;        // Số lượt đã bán

  const PriceAndSold({
    super.key,
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
  });

  String _formatNumber(int number) {
    if (number >= 1000) {
      final double k = number / 1000;
      return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String get discountPercent {
    if (oldPrice <= currentPrice) return '0';
    final discount = ((oldPrice - currentPrice) / oldPrice * 100).toStringAsFixed(0);
    return discount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === TIÊU ĐỀ + GIÁ + GIẢM GIÁ ===
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              '\$${currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${oldPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            if (discountPercent != '0')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-$discountPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // === ĐƯỜNG KẺ MỎNG ===
        Container(
          height: 0.5,
          color: Colors.grey.shade300,
        ),

        const SizedBox(height: 12),

        // === RATING + LƯỢT ĐÁNH GIÁ + ĐÃ BÁN ===
        Row(
          children: [
            // Rating + số review
            Row(
              children: [
                const Icon(LucideIcons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${_formatNumber(reviewCount)})',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Đường kẻ dọc phân cách
            Container(
              width: 1,
              height: 16,
              color: Colors.grey.shade400,
            ),

            const SizedBox(width: 16),

            // Đã bán
            Text(
              'Đã bán ${_formatNumber(soldCount)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}