// lib/admin/features/product/presentation/screens/create_product_page_2.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateProductPage2 extends StatefulWidget {
  final int brandId;
  final String brandName;
  final int productId;

  const CreateProductPage2({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.productId,
  });

  @override
  State<CreateProductPage2> createState() => _CreateProductPage2State();
}

class _CreateProductPage2State extends State<CreateProductPage2> {
  // Dữ liệu fix cứng giống sample API
  final List<Map<String, dynamic>> _colors = [
    {
      'hex': '#4B332B',
      'name': 'Nâu',
      'hasImages': true,
    },
    {
      'hex': '#000000',
      'name': 'Đen',
      'hasImages': true,
    },
  ];

  final List<Map<String, dynamic>> _variants = [
    {'color': '#4B332B', 'size': 'S', 'stock': 10},
    {'color': '#4B332B', 'size': 'M', 'stock': 10},
    {'color': '#4B332B', 'size': 'L', 'stock': 10},
    {'color': '#4B332B', 'size': 'XL', 'stock': 10},
    {'color': '#000000', 'size': 'S', 'stock': 10},
    {'color': '#000000', 'size': 'M', 'stock': 10},
    {'color': '#000000', 'size': 'L', 'stock': 10},
    {'color': '#000000', 'size': 'XL', 'stock': 10},
  ];

  void _simulateComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sản phẩm đã được tạo thành công! (demo)'),
        backgroundColor: Colors.green,
      ),
    );
    // Quay về danh sách sản phẩm
    context.go('/brands/products/${widget.brandId}?name=${Uri.encodeComponent(widget.brandName)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          'Thêm Sản Phẩm Mới - Bước 2',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sản phẩm ID: ${widget.productId} - ${widget.brandName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Phần màu sắc
            const Text('Màu sắc', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._colors.map((color) {
              final hex = color['hex'] as String;
              final colorValue = int.parse(hex.replaceFirst('#', '0xFF'));
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${color['name']} (${hex})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Ảnh đại diện cho màu:'),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: color['hasImages']
                              ? Image.network(
                            'https://via.placeholder.com/300x120?text=${color['name']}+Images',
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Thêm / thay ảnh'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 32),

            // Phần variants
            const Text('Biến thể (Variants)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ..._variants.map((v) {
                      final hex = v['color'] as String;
                      final colorValue = int.parse(hex.replaceFirst('#', '0xFF'));
                      return ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text('Size ${v['size']} - Stock: ${v['stock']}'),
                        subtitle: Text('Màu: ${hex}'),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Quay lại Bước 1'),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _simulateComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hoàn thành'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}