// lib/customer/views/product/widgets/product_detail/body/recommendations_section.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_recommendations_api.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/widgets/product_grid_item.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_detail_screen.dart';

class RecommendationsSection extends StatefulWidget {
  final int productId;

  const RecommendationsSection({super.key, required this.productId});

  @override
  State<RecommendationsSection> createState() => _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {
  late Future<List<RecommendedProduct>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductRecommendationsApi.getRecommendations(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecommendedProduct>>(
      future: _future,
      builder: (context, snapshot) {
        // Không hiển thị gì khi đang load hoặc lỗi hoặc rỗng
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final products = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm bạn có thể thích',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductGridItem(
                  productId: product.id,
                  imageUrl: product.imageUrl,
                  name: product.name,
                  price: product.price.toDouble(),
                  discountPct: product.discountPct > 0 ? product.discountPct : null,
                  priceAfter: product.discountPct > 0 ? product.priceAfter : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}