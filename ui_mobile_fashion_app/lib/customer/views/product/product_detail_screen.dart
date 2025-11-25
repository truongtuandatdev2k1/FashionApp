// lib/customer/views/product/widgets/product_detail/product_detail_screen.dart

import 'package:flutter/material.dart';

import 'widgets/product_detail/header.dart';
import 'widgets/product_detail/body/image_section.dart';
import 'widgets/product_detail/body/brand_rating.dart';
import 'widgets/product_detail/body/price_sold.dart';
import 'widgets/product_detail/body/size_guide_section.dart';
import 'widgets/product_detail/body/description.dart';
import 'widgets/product_detail/bottom_action_bar.dart';
import 'widgets/product_detail/body/mock_product_data.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = mockProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Ảnh sản phẩm
              SliverToBoxAdapter(
                child: ProductImageSection(imageUrls: product.imageUrls),
              ),

              // Nội dung chi tiết
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Thương hiệu
                      BrandRating(
                        brandName: product.brandName,
                        brandLogoUrl: product.brandLogoUrl,
                      ),
                      const SizedBox(height: 16),

                      // 2. Giá + rating + đã bán
                      PriceAndSold(
                        title: product.title,
                        currentPrice: product.currentPrice,
                        oldPrice: product.oldPrice,
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        soldCount: product.soldCount,
                      ),
                      const SizedBox(height: 24),

                      // 3. Bảng size + gợi ý (đã nâng cấp đẹp hơn)
                      const SizeGuideSection(),
                      const SizedBox(height: 24),

                      // 4. Mô tả sản phẩm — ĐÃ CHUYỂN XUỐNG DƯỚI BẢNG SIZE
                      ProductDescription(description: product.description),

                      // Khoảng trống cho bottom bar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProductDetailHeader(
              onBack: () => Navigator.of(context).pop(),
              onFavorite: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm vào yêu thích')),
                );
              },
            ),
          ),

          // Bottom Action Bar
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(),
          ),
        ],
      ),
    );
  }
}