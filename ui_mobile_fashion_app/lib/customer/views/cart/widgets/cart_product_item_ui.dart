import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../logic/cart/cart_api.dart';
import '../../common/navigation_helper.dart';

class CartProductItemUI extends StatelessWidget {
  final CartItem item;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  const CartProductItemUI({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox căn giữa theo ảnh
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              activeColor: Colors.blue,
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.grey.shade400),
              onChanged: (bool? value) {
                onSelectionChanged(value ?? false);
              },
            ),
          ),
          const SizedBox(width: 2),

          // Ảnh + thông tin — bấm để xem chi tiết sản phẩm
          Expanded(
            child: GestureDetector(
              onTap: () => NavigationHelper.toProductDetail(
                context,
                productId: product.productId,
              ),
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ảnh sản phẩm
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.fullImageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Thông tin sản phẩm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(int.parse(product.color.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Size: ${product.size}, Số lượng: ${item.quantity} ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Text(
                          currencyFormat.format(item.currentPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}