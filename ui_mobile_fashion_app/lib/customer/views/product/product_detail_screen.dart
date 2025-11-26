// lib/customer/views/product/widgets/product_detail/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_detail_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_detail_model.dart';
import 'widgets/product_detail/header.dart';
import 'widgets/product_detail/body/image_section.dart';
import 'widgets/product_detail/body/brand_rating.dart';
import 'widgets/product_detail/body/price_sold.dart';
import 'widgets/product_detail/body/size_guide_section.dart';
import 'widgets/product_detail/body/description.dart';
import 'widgets/product_detail/bottom_action_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDetailModel> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductDetailApi.getProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ProductDetailModel>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final product = snapshot.data!;
            final allImages = <String>{};
            for (var v in product.variants) {
              allImages.addAll(v.images);
            }
            final imageList =
                allImages.isNotEmpty ? allImages.toList() : [product.imageUrl];

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProductImageSection(imageUrls: imageList),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BrandRating(
                              brandName: product.brand.name,
                              brandLogoUrl: product.brand.logoUrl,
                            ),
                            const SizedBox(height: 16),
                            PriceAndSold(
                              title: product.name,
                              currentPrice: product.priceAfter.toDouble(),
                              oldPrice: product.price.toDouble(),
                              rating: product.ratingAvg,
                              reviewCount: 0, // API chưa có
                              soldCount: product.soldCount,
                            ),
                            const SizedBox(height: 24),
                            const SizeGuideSection(),
                            const SizedBox(height: 24),
                            ProductDescription(
                              description: product.description,
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomActionBar(),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
