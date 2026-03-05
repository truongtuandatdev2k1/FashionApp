// lib/customer/views/saved/widgets/saved_product_item.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/saved_api.dart';

class SavedProductItem extends StatelessWidget {
  final WishlistProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const SavedProductItem({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
  });

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPct > 0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hình ảnh sản phẩm
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    product.fullImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 110,
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.black26,
                        size: 28,
                      ),
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 90,
                        height: 110,
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.black26,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 14),

                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng 1: Tên sản phẩm (1 dòng, overflow ellipsis)
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Hàng 2: Giá sau giảm
                      Text(
                        _formatPrice(product.priceAfter),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Hàng 3: Badge % giảm + giá gốc gạch ngang
                      if (hasDiscount)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${product.discountPct}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE57373),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatPrice(product.price),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Icon trái tim bên phải cùng
                GestureDetector(
                  onTap: onFavoriteTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE57373),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Đường kẻ phân cách mỏng, mờ
        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey.withOpacity(0.25),
          indent: 0,
          endIndent: 0,
        ),
      ],
    );
  }
}