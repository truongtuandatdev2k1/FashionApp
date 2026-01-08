// lib/customer/views/home/widgets/horizontal_product_section.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_data.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_detail_screen.dart';
import 'product_item.dart';
import '../../product/product_list_screen.dart';

class HorizontalProductSection extends StatelessWidget {
  final String title;
  final List<ProductData> products;

  const HorizontalProductSection({
    super.key,
    required this.title,
    required this.products,
  });

  String _mapTitleToFilter(String title) {
    switch (title) {
      case 'Bán chạy nhất':
        return 'bestseller';
      // case 'Sản phẩm mới':
      //   return 'new';
      case 'Hot trend':
        return 'hottrend';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề + "Xem tất cả"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ProductListScreen(
                            title: title,
                            filter: _mapTitleToFilter(title),
                          ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Danh sách cuộn ngang
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductItem(
                imageUrl: product.imageUrl,
                name: product.name,
                price: product.price.toDouble(),
                discountPct: product.discountPct,
                priceAfter: product.priceAfter.toDouble(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ProductDetailScreen(
                            productId: product.id,
                          ), // DÙNG ID
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
