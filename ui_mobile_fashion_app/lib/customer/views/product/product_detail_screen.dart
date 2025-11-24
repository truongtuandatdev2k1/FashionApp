// lib/customer/views/product/widgets/product_detail/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'widgets/product_detail/header.dart';
import 'widgets/product_detail/body/image_section.dart';
import 'widgets/product_detail/body/brand_rating.dart';
import 'widgets/product_detail/body/price_sold.dart';
import 'widgets/product_detail/body/size_selector.dart';
import 'widgets/product_detail/body/color_selector.dart';
import 'widgets/product_detail/body/description.dart';
import 'widgets/product_detail/bottom_action_bar.dart';

// Import dữ liệu đã tách riêng
import 'widgets/product_detail/body/mock_product_data.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu được lấy từ file riêng, dễ thay thế sau này
    final product = mockProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- NỘI DUNG CHÍNH ---
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
                      BrandRating(
                        brandName: product.brandName,
                        // rating: product.rating,
                        brandLogoUrl: product.brandLogoUrl,
                      ),
                      const SizedBox(height: 16),

                      PriceAndSold(
                        title: product.title,
                        currentPrice: product.currentPrice,
                        oldPrice: product.oldPrice,
                        rating: product.rating,          // THÊM DÒNG NÀY
                        reviewCount: product.reviewCount, // THÊM DÒNG NÀY
                        soldCount: product.soldCount,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizeSelector(
                              sizes: product.sizes,
                              initialSize: 'M',
                            ),
                          ),
                          const SizedBox(width: 20),
                          ColorSelector(
                            colors: product.colors,
                            initialColor: Colors.teal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      ProductDescription(description: product.description),
                      const SizedBox(height: 100), // Để bottom bar không che
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Header đè lên ảnh ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProductDetailHeader(
              onBack: () => Navigator.pop(context),
              onFavorite: () {},
            ),
          ),

          // --- Bottom Action Bar ---
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