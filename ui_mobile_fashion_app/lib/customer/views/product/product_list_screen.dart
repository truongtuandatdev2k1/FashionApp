// lib/customer/views/product/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_list_controller.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_detail_screen.dart';
import 'widgets/product_grid_item.dart';

class ProductListScreen extends StatelessWidget {
  final String title;
  final String filter;
  final int? brandId; // ← THÊM: optional, truyền khi từ brand

  const ProductListScreen({
    super.key,
    required this.title,
    required this.filter,
    this.brandId, // ← THÊM
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductListController(
        filter: filter,
        brandId: brandId, // ← THÊM
      ),
      child: _ProductListView(title: title),
    );
  }
}

class _ProductListView extends StatefulWidget {
  final String title;

  const _ProductListView({required this.title});

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<ProductListController>();
    if (controller.shouldLoadMore(
      _scrollController.position.pixels,
      _scrollController.position.maxScrollExtent,
    )) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductListController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _buildBody(context, controller),
    );
  }

  Widget _buildBody(BuildContext context, ProductListController controller) {
    if (controller.products.isEmpty && controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(controller.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.loadMore,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (controller.products.isEmpty) {
      return const Center(
        child: Text(
          'Không có sản phẩm nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 20,
          childAspectRatio: 0.68,
        ),
        itemCount: controller.products.length + (controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final product = controller.products[index];
          return ProductGridItem(
            imageUrl: product.imageUrl,
            name: product.name,
            price: product.price.toDouble(),
            discountPct: product.discountPct,
            priceAfter: product.priceAfter.toDouble(),
            productId: product.id,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: product.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}