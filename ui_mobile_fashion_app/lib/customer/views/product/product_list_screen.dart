// lib/customer/views/product/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_list_controller.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_data.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_detail_screen.dart';
import 'widgets/product_grid_item.dart';

class ProductListScreen extends StatelessWidget {
  final String title;
  final String filter;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductListController(filter: filter),
      child: _ProductListView(title: title),
    );
  }
}

class _ProductListView extends StatelessWidget {
  final String title;

  const _ProductListView({required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductListController>();
    final scrollController = ScrollController();

    scrollController.addListener(() {
      if (controller.shouldLoadMore(
        scrollController.position.pixels,
        scrollController.position.maxScrollExtent,
      )) {
        controller.loadMore();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _buildBody(context, controller, scrollController),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ProductListController controller,
      ScrollController scrollController,
      ) {
    if (controller.products.isEmpty && controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
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

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: GridView.builder(
        controller: scrollController,
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
            ),
          );
        },
      ),
    );
  }
}