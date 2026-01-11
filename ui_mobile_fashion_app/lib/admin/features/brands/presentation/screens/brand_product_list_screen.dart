// lib/admin/features/product/presentation/screens/brand_product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/product_list_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/widgets/product_card.dart';
class BrandProductListScreen extends StatefulWidget {
  final int brandId;
  final String brandName;

  const BrandProductListScreen({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<BrandProductListScreen> createState() => _BrandProductListScreenState();
}

class _BrandProductListScreenState extends State<BrandProductListScreen> {
  final _controller = ProductListController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.fetchProducts(brandId: widget.brandId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Sản phẩm: ${widget.brandName}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _controller.products.isEmpty
          ? _buildEmptyState()
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tính toán số cột dựa trên chiều rộng màn hình (Responsive)
            int crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : 2);

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.72,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Chưa có sản phẩm nào cho nhãn hàng này",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}