// lib/admin/features/brands/presentation/screens/brand_product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/product_list_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/widgets/product_card.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/product_delete_controller.dart';
import '../../../../../core/config/app_config.dart';

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
  final _deleteController = ProductDeleteController(); // Controller xóa

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.fetchProducts(brandId: widget.brandId);
    if (mounted) setState(() {});
  }

  // 1. Hộp thoại xác nhận (Giữ nguyên, chỉ đóng hộp thoại này)
  void _confirmDelete(int productId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa sản phẩm \"$productName\" không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Chỉ đóng dialog xác nhận
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng dialog xác nhận trước
              _handleDelete(productId); // Sau đó mới gọi API xóa
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 2. Logic xóa (KHÔNG DÙNG showDialog loading nữa)
  Future<void> _handleDelete(int productId) async {
    // Gọi API (Trạng thái loading sẽ được cập nhật qua ListenableBuilder)
    final success = await _deleteController.deleteProduct(productId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm thành công'), backgroundColor: Colors.green),
        );
        // Load lại danh sách sản phẩm ngay tại trang này
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_deleteController.errorMessage ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng ListenableBuilder để lắng nghe trạng thái xóa (Loading/Success/Error)
    return ListenableBuilder(
      listenable: _deleteController,
      builder: (context, child) {
        return Stack(
          children: [
            // Giao diện chính
            Scaffold(
              backgroundColor: Colors.white,
              appBar: _buildAppBar(),
              body: _buildBody(),
            ),

            // Lớp phủ Loading (Overlay)
            // Chỉ hiện khi đang xóa, đè lên toàn bộ màn hình để chặn thao tác
            if (_deleteController.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final int productCount = _controller.products.length;
    return AppBar(
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
                '${AppConfig.imageBaseUrl}${widget.logoUrl}',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 20, color: Colors.grey),
              )
                  : const Icon(Icons.business, size: 20, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "${widget.brandName} ($productCount)",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              await context.push(
                '/brands/products/create/step1?brandId=${widget.brandId}&brandName=${widget.brandName}',
              );
              _loadData();
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text("Thêm sản phẩm"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    final int productCount = _controller.products.length;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int crossAxisCount = constraints.maxWidth > 1200
              ? 5
              : constraints.maxWidth > 800
              ? 3
              : 2;

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
            itemCount: productCount,
            itemBuilder: (context, index) {
              final product = _controller.products[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ProductCard(
                  product: product,
                  onEdit: () {
                    // TODO: Điều hướng sang trang sửa
                  },
                  onDelete: () {
                    _confirmDelete(product.id, product.name);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 90, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            "Chưa có sản phẩm nào cho nhãn hàng này",
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text("Hãy thêm sản phẩm mới ngay bây giờ!", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}