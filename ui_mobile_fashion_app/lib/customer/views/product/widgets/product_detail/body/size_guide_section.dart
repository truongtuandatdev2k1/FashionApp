// lib/customer/views/product/widgets/product_detail/body/size_guide_section.dart

import 'package:flutter/material.dart';

class SizeGuideSection extends StatelessWidget {
  const SizeGuideSection({super.key});

  // Size gợi ý (sau này có thể tính tự động từ profile người dùng)
  final String recommendedSize = 'L';

  final List<Map<String, String>> sizeTable = const [
    {'size': 'S',   'weight': '45-55 kg', 'height': '1.55 - 1.65 m'},
    {'size': 'M',   'weight': '55-65 kg', 'height': '1.60 - 1.75 m'},
    {'size': 'L',   'weight': '65-75 kg', 'height': '1.70 - 1.80 m'},
    {'size': 'XL',  'weight': '75-85 kg', 'height': '1.75 - 1.85 m'},
    {'size': 'XXL', 'weight': '85-95 kg', 'height': '1.80 - 1.90 m'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === GỢI Ý SIZE - NỔI BẬT VỚI NỀN ĐEN ===
        Row(
          children: [
            const Text(
              'Gợi ý size phù hợp với bạn: ',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recommendedSize,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // === TIÊU ĐỀ BẢNG SIZE ===
        const Text(
          'Bảng hướng dẫn chọn size',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // === BẢNG SIZE ĐẸP ===
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Center(child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 3, child: Center(child: Text('Cân nặng', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 3, child: Center(child: Text('Chiều cao', style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),

              // Rows
              ...sizeTable.map((row) {
                final isRecommended = row['size'] == recommendedSize;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isRecommended ? Colors.black.withOpacity(0.05) : null,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            row['size']!,
                            style: TextStyle(
                              fontWeight: isRecommended ? FontWeight.bold : FontWeight.w600,
                              color: isRecommended ? Colors.black : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 3, child: Center(child: Text(row['weight']!))),
                      Expanded(flex: 3, child: Center(child: Text(row['height']!))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}