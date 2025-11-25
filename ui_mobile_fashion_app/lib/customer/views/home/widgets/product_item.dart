// lib/customer/views/home/widgets/product_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../product/product_detail_screen.dart'; // ĐÃ THÊM

class ProductItem extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double price;
  final int? discountPct;
  final double? priceAfter;
  final VoidCallback? onTap; // ĐÃ THÊM

  const ProductItem({
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
      onTap: onTap ?? () => Navigator.push( // ĐÃ THÊM: Mặc định đi đến chi tiết
        context,
        MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ẢNH + TAG % GIẢM
            SizedBox(
              height: 165,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              maxLines: 1,               // chỉ hiển thị 1 dòng
              overflow: TextOverflow.ellipsis, // nếu dài thì thêm "..."
            ),

            const SizedBox(height: 4),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount && priceAfter != null)
                  Text(
                    '${priceAfter!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                if (hasDiscount) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      decoration: hasDiscount ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
          child: Icon(Icons.error_outline, color: Colors.red, size: 32),
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
              const Icon(Icons.image, size: 40, color: Colors.grey),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
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