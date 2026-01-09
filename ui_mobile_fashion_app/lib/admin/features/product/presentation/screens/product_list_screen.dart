// file: lib/admin/features/product/presentation/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/product_list_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProductListController();
    _controller.fetchProducts().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh Sách Sản Phẩm',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm sản phẩm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_controller.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_controller.errorMessage != null)
              Expanded(child: Center(child: Text(_controller.errorMessage!)))
            else ...[
              Text(
                'Tổng cộng: ${_controller.products.length} sản phẩm',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    if (constraints.maxWidth > 1600) {
                      crossAxisCount = 6;
                    } else if (constraints.maxWidth > 1400)
                      // ignore: curly_braces_in_flow_control_structures
                      crossAxisCount = 5;
                    else if (constraints.maxWidth > 1100)
                      // ignore: curly_braces_in_flow_control_structures
                      crossAxisCount = 4;
                    else if (constraints.maxWidth > 800)
                      // ignore: curly_braces_in_flow_control_structures
                      crossAxisCount = 3;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        // GIẢM số này xuống để Card CAO hơn (Rộng / Cao)
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _controller.products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: _controller.products[index],
                          onEdit: () {},
                          onDelete: () {},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
