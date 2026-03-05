// lib/customer/views/product/widgets/product_detail/body/brand_rating.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart'; // ĐÃ THÊM

class BrandRating extends StatelessWidget {
  final String brandName;
  final String brandLogoUrl;

  const BrandRating({
    super.key,
    required this.brandName,
    required this.brandLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // === PHẦN TRÁI: Logo + Tên thương hiệu + Verified ===
        Row(
          children: [
            // Logo thương hiệu
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 24,
                  maxHeight: 24,
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: CachedNetworkImage(
                  imageUrl: brandLogoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[300],
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Text(
                      brandName.isNotEmpty ? brandName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 10),
            // Text(
            //   brandName,
            //   style: const TextStyle(
            //     fontSize: 17,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(width: 6),
            const Icon(Icons.verified, color: Colors.blue, size: 14),
          ],
        ),

        // === PHẦN PHẢI: Mũi tên sang phải (thay thế rating) ===
        GestureDetector(
          onTap: () {
            // TODO: Điều hướng đến trang thương hiệu hoặc trang đánh giá
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xem chi tiết thương hiệu')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   'Xem shop',
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //     color: Colors.black87,
                //   ),
                // ),
                SizedBox(width: 4),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}