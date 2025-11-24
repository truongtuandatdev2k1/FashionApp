// lib/customer/views/product/widgets/product_detail/body/description.dart
import 'package:flutter/material.dart';

class ProductDescription extends StatelessWidget {
  final String description;

  const ProductDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final short = description.split('.').take(1).join('.') + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(short, style: const TextStyle(fontSize: 16, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xem thêm mô tả...'))),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
              label: const Text('Read More', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}