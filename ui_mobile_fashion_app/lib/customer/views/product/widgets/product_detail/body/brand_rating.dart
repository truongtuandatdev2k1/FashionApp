// lib/customer/views/product/widgets/product_detail/body/brand_rating.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BrandRating extends StatelessWidget {
  final String brandName;
  final double rating;
  final String brandLogoUrl;

  const BrandRating({
    super.key,
    required this.brandName,
    required this.rating,
    required this.brandLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // LOGO GIỮ TỈ LỆ GỐC, TỰ ĐỘNG RESIZE
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 20,
                  maxHeight: 20,
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: CachedNetworkImage(
                  imageUrl: brandLogoUrl,
                  fit: BoxFit.contain, // GIỮ TỈ LỆ GỐC
                  placeholder: (_, __) => Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey[300],
                    child: const Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 20,
                    height: 20,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Text(
                      brandName.isNotEmpty ? brandName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              brandName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}