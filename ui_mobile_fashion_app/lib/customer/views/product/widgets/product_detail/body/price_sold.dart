// lib/customer/views/product/widgets/product_detail/body/price_sold.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PriceAndSold extends StatelessWidget {
  final String title;
  final double currentPrice; // Đơn vị: nghìn đồng (VD: 450.99 = 450.990 đ)
  final double oldPrice;
  final double rating;
  final int reviewCount;
  final int soldCount;

  const PriceAndSold({
    super.key,
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
  });

  // Định dạng số tiền Việt Nam: 1234567 → 1.234.567 đ
  String _formatCurrency(double price) {
    final String raw = price.toStringAsFixed(0); // bỏ phần thập phân nếu có
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String result = raw.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return '$result đ';
  }

  // Format số lượng (1.2k, 15k…)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      final double m = number / 1000000;
      return m % 1 == 0 ? '${m.toInt()}tr' : '${m.toStringAsFixed(1)}tr';
    }
    if (number >= 1000) {
      final double k = number / 1000.0;
      return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String get discountPercent {
    if (oldPrice <= currentPrice) return '0';
    final discount = ((oldPrice - currentPrice) / oldPrice * 100)
        .toStringAsFixed(0);
    return discount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề sản phẩm
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Giá hiện tại + giá cũ + % giảm
        Row(
          children: [
            Text(
              _formatCurrency(currentPrice),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatCurrency(oldPrice),
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

        // Đường kẻ ngang
        Container(height: 0.5, color: Colors.grey.shade300),
        const SizedBox(height: 12),

        // Rating + lượt đánh giá + đã bán
        Row(
          children: [
            // Rating
            Row(
              children: [
                const Icon(LucideIcons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${_formatNumber(reviewCount)})',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(width: 1, height: 16, color: Colors.grey.shade400),
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
