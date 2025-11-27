// lib/customer/views/product/widgets/product_grid_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductGridItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final int? discountPct;
  final double? priceAfter;
  final VoidCallback onTap; // THÊM DÒNG NÀY
  final int productId; // GIỮ LẠI ĐỂ DỄ DÙNG SAU NÀY (TÙY CHỌN)

  const ProductGridItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.discountPct,
    this.priceAfter,
    required this.onTap, // BẮT BUỘC TRUYỀN
    required this.productId, // CÓ THỂ DÙNG HOẶC KHÔNG
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountPct != null && discountPct! > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ẢNH + TAG GIẢM GIÁ
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget:
                      (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${discountPct!}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (hasDiscount && priceAfter != null)
                Text(
                  '${priceAfter!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                '${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                style: TextStyle(
                  fontSize: 11,
                  color: hasDiscount ? Colors.grey[500] : Colors.black,
                  decoration: hasDiscount ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
