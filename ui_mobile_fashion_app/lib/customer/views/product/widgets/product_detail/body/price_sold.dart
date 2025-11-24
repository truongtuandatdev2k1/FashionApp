// lib/customer/views/product/widgets/product_detail/body/price_sold.dart
import 'package:flutter/material.dart';

class PriceAndSold extends StatelessWidget {
  final String title;
  final double currentPrice;
  final double oldPrice;
  final int soldCount;

  const PriceAndSold({
    super.key,
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.soldCount,
  });

  String _formatSold(int count) => count >= 10000 ? '${(count / 1000).toStringAsFixed(0)}k+ Sold' : '$count Sold';

  @override
  Widget build(BuildContext context) {
    final discount = ((oldPrice - currentPrice) / oldPrice * 100).toStringAsFixed(0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(width: 10),
                Text('\$${oldPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                  child: Text('-${discount}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        Text(_formatSold(soldCount), style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}