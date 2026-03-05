// lib/customer/views/product/widgets/product_detail/bottom_action_bar.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_detail_screen.dart';
import 'size_color_selector_sheet.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  void _showSelectorSheet(BuildContext context, {required bool isBuyNow}) {
    final state = context.findAncestorStateOfType<ProductDetailScreenState>();
    final product = state?.currentProduct;

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải sản phẩm...')),
      );
      return;
    }

    SizeColorSelectorSheet.show(
      context,
      product: product,
      isBuyNow: isBuyNow,
      onConfirm: () {
        final message =
        isBuyNow ? 'Đã chọn "Mua ngay"!' : 'Đã thêm vào giỏ hàng!';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  String _formatCurrency(double price) {
    final String raw = price.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return raw.replaceAllMapped(reg, (m) => '${m[1]}.') + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<ProductDetailScreenState>();
    final product = state?.currentProduct;
    final priceText =
    product != null ? _formatCurrency(product.priceAfter) : '...';

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== BUTTON TRÁI: Thêm giỏ hàng =====
                  Expanded(
                    child: Material(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showSelectorSheet(context, isBuyNow: false),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.shoppingCart,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Thêm giỏ hàng',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  // ===== BUTTON PHẢI: Mua ngay =====
                  Expanded(
                    child: Material(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showSelectorSheet(context, isBuyNow: true),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Mua ngay',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      priceText,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFCFD8DC),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '| Freeship',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFCFD8DC),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      );
    }
}