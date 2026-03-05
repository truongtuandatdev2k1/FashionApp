// lib/customer/views/saved/widgets/saved_product_item.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/add_wishlist_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/remove_wishlist_api.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/saved_api.dart';

class SavedProductItem extends StatefulWidget {
  final WishlistProduct product;
  final VoidCallback? onTap;

  const SavedProductItem({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<SavedProductItem> createState() => _SavedProductItemState();
}

class _SavedProductItemState extends State<SavedProductItem> {
  // true = đang yêu thích (đỏ nhạt), false = đã bỏ (viền đen)
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = true; // Mặc định đang có trong danh sách yêu thích
  }

  Future<void> _toggleFavorite() async {
    // Đổi UI ngay lập tức, không chờ API
    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      if (_isFavorited) {
        // Vừa bật lại → thêm vào wishlist
        await AddWishlistApi.addToWishlist(widget.product.id);
      } else {
        // Vừa tắt → xóa khỏi wishlist
        await RemoveWishlistApi.removeFromWishlist(widget.product.id);
      }
    } catch (_) {
      // API lỗi → hoàn tác UI về trạng thái trước
      if (mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      }
    }
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product.discountPct > 0;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
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
                    widget.product.fullImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
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
                        width: 70,
                        height: 70,
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
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _formatPrice(widget.product.priceAfter),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

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
                                '-${widget.product.discountPct}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE57373),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatPrice(widget.product.price),
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

                // Icon trái tim toggle
                GestureDetector(
                  onTap: _toggleFavorite,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _isFavorited
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorited
                          ? const Color(0xFFE57373)
                          : Colors.black,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey.withOpacity(0.25),
        ),
      ],
    );
  }
}