// lib/customer/views/product/widgets/product_grid_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../product_detail_screen.dart'; // ĐÃ THÊM

class ProductGridItem extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double price;
  final int? discountPct;
  final double? priceAfter;
  final VoidCallback? onTap; // ĐÃ THÊM

  const ProductGridItem({
    super.key,
    this.imageUrl,
    required this.name,
    required this.price,
    this.discountPct,
    this.priceAfter,
    this.onTap, // ĐÃ THÊM
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountPct != null && discountPct! > 0;

    return InkWell(
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ẢNH + TAG % GIẢM
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImage(),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '-${discountPct!}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // TÊN SẢN PHẨM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6),

            // GIÁ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount && priceAfter != null)
                    Text(
                      '${priceAfter!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  if (hasDiscount) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: hasDiscount ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red, size: 40),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Center(
          child: Stack(
            children: [
              const Icon(Icons.image, size: 50, color: Colors.grey),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Container(
                  height: 2,
                  color: Colors.red,
                  transform: Matrix4.rotationZ(0.785),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}