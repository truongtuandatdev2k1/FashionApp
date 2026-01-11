// lib/admin/features/product/presentation/screens/brand_product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/product_list_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/widgets/product_card.dart';

class BrandProductListScreen extends StatefulWidget {
  final int brandId;
  final String brandName;
  final String? logoUrl;

  const BrandProductListScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    this.logoUrl,
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
    // Truyền brandId để API chỉ trả về sản phẩm của thương hiệu này
    await _controller.fetchProducts(brandId: widget.brandId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int productCount = _controller.products.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Logo thương hiệu
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.logoUrl != null && widget.logoUrl!.isNotEmpty
                    ? Image.network(
                  'https://api.caibang.online${widget.logoUrl}',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.business,
                    size: 20,
                    color: Colors.grey,
                  ),
                )
                    : const Icon(
                  Icons.business,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tên thương hiệu + số lượng sản phẩm
            Expanded(
              child: Text(
                "${widget.brandName} ($productCount)",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200
                ? 5
                : (constraints.maxWidth > 800 ? 3 : 2);

            // Trường hợp chưa có sản phẩm nào
            if (productCount == 0) {
              return _buildEmptyState();
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.75,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              // +1 vì có thêm card "Thêm sản phẩm"
              itemCount: productCount + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddProductCard();
                }

                return ProductCard(
                  product: _controller.products[index - 1],
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

  // Card "Thêm sản phẩm mới"
  Widget _buildAddProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Điều hướng đến màn hình thêm sản phẩm mới
          // Ví dụ: context.push('/admin/products/add?brandId=${widget.brandId}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 50,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              "Thêm sản phẩm mới",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state khi chưa có sản phẩm
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Chưa có sản phẩm nào cho nhãn hàng này",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Điều hướng đến màn hình thêm sản phẩm
            },
            icon: const Icon(Icons.add),
            label: const Text("Thêm sản phẩm mới"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}