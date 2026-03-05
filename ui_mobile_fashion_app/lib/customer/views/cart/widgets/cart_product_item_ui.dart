import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../logic/cart/cart_api.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox chọn sản phẩm
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Checkbox(
              value: isSelected,
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onChanged: (bool? value) {
                onSelectionChanged(value ?? false);
              },
            ),
          ),
          const SizedBox(width: 2),

          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.fullImageUrl,
              width: 90,
              height: 90,
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
                // Tên sản phẩm - chỉ 1 dòng
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Màu (hình tròn) + Size
                Row(
                  children: [
                    // Hình tròn hiển thị màu
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
                      'Size: ${product.size}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Giá + số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(item.currentPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Khối số lượng: - | 1 | + (giữ nguyên như bạn mong muốn)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút trừ (-)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                          ),
                          height: 24,
                          width: 26,
                          child: IconButton(
                            icon: const Icon(Icons.remove, size: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 14),
                            onPressed: () {
                              // TODO: giảm số lượng
                            },
                            color: Colors.black87,
                          ),
                        ),

                        // Số lượng
                        Container(
                          color: Colors.grey[200],
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Nút cộng (+)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                          ),
                          height: 24,
                          width: 28,
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 14),
                            onPressed: () {
                              // TODO: tăng số lượng
                            },
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Khoảng cách giữa nội dung sản phẩm và đường kẻ ngăn cách
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}