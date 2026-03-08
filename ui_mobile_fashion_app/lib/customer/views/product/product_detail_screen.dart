// lib/customer/views/product/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_detail_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/add_wishlist_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/remove_wishlist_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/saved_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_detail_model.dart';
import 'widgets/product_detail/header.dart';
import 'widgets/product_detail/body/image_section.dart';
import 'widgets/product_detail/body/brand_rating.dart';
import 'widgets/product_detail/body/price_sold.dart';
import 'widgets/product_detail/body/size_guide_section.dart';
import 'widgets/product_detail/body/description.dart';
import 'widgets/product_detail/body/recommendations_section.dart'; // ← THÊM
import 'widgets/product_detail/bottom_action_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDetailModel> _productFuture;

  AsyncSnapshot<ProductDetailModel> _snapshot = const AsyncSnapshot.nothing();

  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductDetailApi.getProduct(widget.productId);
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final wishlist = await SavedApi.getWishlist();
      final isFav = wishlist.items.any((item) => item.id == widget.productId);
      if (mounted) {
        setState(() {
          _isFavorited = isFav;
        });
      }
    } catch (_) {}
  }

  ProductDetailModel? get currentProduct {
    if (!mounted) return null;
    if (_snapshot.connectionState == ConnectionState.done &&
        _snapshot.hasData) {
      return _snapshot.data;
    }
    return null;
  }

  List<String> get allProductImages {
    final product = currentProduct;
    if (product == null) return [];

    final images = <String>{product.imageUrl};
    for (var v in product.variants) {
      images.addAll(v.images);
    }
    return images.toList();
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      if (_isFavorited) {
        await AddWishlistApi.addToWishlist(widget.productId);
      } else {
        await RemoveWishlistApi.removeFromWishlist(widget.productId);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ProductDetailModel>(
        future: _productFuture,
        builder: (context, snapshot) {
          _snapshot = snapshot;

          if (snapshot.hasData) {
            final product = snapshot.data!;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProductImageSection(imageUrls: allProductImages),
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
                              reviewCount: 0,
                              soldCount: product.soldCount,
                            ),
                            const SizedBox(height: 12),
                            const SizeGuideSection(),
                            const SizedBox(height: 24),
                            ProductDescription(
                              description: product.description,
                            ),
                            const SizedBox(height: 32),

                            // ===== GỢI Ý SẢN PHẨM =====
                            RecommendationsSection(
                              productId: widget.productId,
                            ),
                            // ===========================

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
                    isFavorited: _isFavorited,
                    onFavorite: _toggleFavorite,
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
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}