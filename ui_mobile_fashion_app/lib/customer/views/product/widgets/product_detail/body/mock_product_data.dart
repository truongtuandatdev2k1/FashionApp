// lib/customer/views/product/widgets/product_detail/body/mock_product_data.dart

import 'package:flutter/material.dart';

class ProductDetails {
  final String brandName;
  final String title;
  final double currentPrice;
  final double oldPrice;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final String description;
  final List<String> sizes;
  final List<Color> colors;
  final List<String> imageUrls;
  final String brandLogoUrl;

  ProductDetails({
    required this.brandName,
    required this.title,
    required this.currentPrice,
    required this.oldPrice,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.imageUrls,
    required this.brandLogoUrl,
  });
}

// Ảnh placeholder để test
const _kPlaceholder =
    'https://i.pinimg.com/1200x/5a/b6/7b/5ab67b2cc631c4fee1941adebfbdb060.jpg';

// Dữ liệu mẫu duy nhất của toàn bộ Product Detail
final ProductDetails mockProduct = ProductDetails(
  brandName: 'H&M',
  title: 'Casual Mandarin Collar Shirt',
  currentPrice: 900.00,
  oldPrice: 1200.00,
  rating: 4.3,
  reviewCount: 1700,
  soldCount: 28600,
  description:
      'Chất liệu cotton mềm mại, thoáng mát. Thiết kế cổ trụ thanh lịch, phù hợp mặc đi làm hoặc đi chơi. Đường may chắc chắn, bền đẹp theo thời gian. Phù hợp với mọi dáng người. Dễ phối đồ với quần jeans, kaki hoặc short',
  sizes: ['S', 'M', 'L', 'XL', 'XXL'],
  colors: [
    Colors.teal,
    Colors.grey.shade300,
    Colors.white,
    Colors.red.shade900,
    Colors.blue.shade900,
    Colors.black,
  ],
  imageUrls: [
    _kPlaceholder,
    _kPlaceholder,
    _kPlaceholder,
    _kPlaceholder,
  ],
  brandLogoUrl:
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWxzF7ValZVpOSk3lDkD52SJLipvmhaXfpAw&s',
);