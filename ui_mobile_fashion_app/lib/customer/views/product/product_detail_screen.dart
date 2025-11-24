// lib/customer/views/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'widgets/product_detail/header.dart';
import 'widgets/product_detail/body/image_section.dart';
import 'widgets/product_detail/body/brand_rating.dart';
import 'widgets/product_detail/body/price_sold.dart';
import 'widgets/product_detail/body/size_selector.dart';
import 'widgets/product_detail/body/color_selector.dart';
import 'widgets/product_detail/body/description.dart';
import 'widgets/product_detail/bottom_action_bar.dart';

// lib/customer/views/product/product_detail_screen.dart
class ProductDetails {
  final String brandName;
  final String title;
  final double currentPrice;
  final double oldPrice;
  final double rating;
  final int soldCount;
  final String description;
  final List<String> sizes;
  final List<Color> colors;
  final List<String> imageUrls;
  final String brandLogoUrl; // ĐÃ THÊM

  ProductDetails({
    required this.brandName,
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.rating,
    required this.soldCount,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.imageUrls,
    required this.brandLogoUrl, // ĐÃ THÊM
  });
}

final _kPlaceholder = 'https://i.pinimg.com/1200x/5a/b6/7b/5ab67b2cc631c4fee1941adebfbdb060.jpg';
final mockProduct = ProductDetails(
  brandName: 'H&M',
  title: 'Casual Mandarin Collar Shirt',
  currentPrice: 900.00,
  oldPrice: 1200.00,
  rating: 4.3,
  soldCount: 10000,
  description: 'Stay stylish with this Men\'s Mandarin Collar Shirt...',
  sizes: ['S', 'M', 'L', 'XL'],
  colors: [Colors.teal, Colors.grey.shade300, Colors.white, Colors.red.shade900, Colors.blue.shade900],
  imageUrls: [_kPlaceholder, _kPlaceholder, _kPlaceholder],
  brandLogoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWxzF7ValZVpOSk3lDkD52SJLipvmhaXfpAw&s', // ĐÃ THÊM
);

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- NỘI DUNG CHÍNH (ẢNH + BODY) ---
          CustomScrollView(
            slivers: [
              // ẢNH TRÀN LÊN DƯỚI
              SliverToBoxAdapter(
                child: ProductImageSection(imageUrls: mockProduct.imageUrls),
              ),
              // NỘI DUNG BODY
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrandRating(
                        brandName: mockProduct.brandName,
                        rating: mockProduct.rating,
                        brandLogoUrl: mockProduct.brandLogoUrl, // ĐÃ THÊM
                      ),
                      const SizedBox(height: 16),
                      PriceAndSold(
                        title: mockProduct.title,
                        currentPrice: mockProduct.currentPrice,
                        oldPrice: mockProduct.oldPrice,
                        soldCount: mockProduct.soldCount,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: SizeSelector(sizes: mockProduct.sizes, initialSize: 'M')),
                          const SizedBox(width: 20),
                          ColorSelector(colors: mockProduct.colors, initialColor: Colors.teal),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ProductDescription(description: mockProduct.description),
                      const SizedBox(height: 100), // Khoảng trống cho Bottom Bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- HEADER ĐÈ LÊN TRÊN ẢNH ---
          // Trong Positioned
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProductDetailHeader(
              onBack: () => Navigator.pop(context), // ĐÃ SỬA
              onFavorite: () {}, // ĐÃ SỬA
            ),
          ),

          // --- BOTTOM ACTION BAR ---
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