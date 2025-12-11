import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../logic/cart/cart_api.dart'; // Để lấy định nghĩa CartItem

class OrderProductItem extends StatelessWidget {
  final CartItem item;

  const OrderProductItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Ảnh sản phẩm
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                product.fullImageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Màu sắc và Kích cỡ
                Text(
                  'Màu: ${product.color} • Size: ${product.size}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text(
                      currencyFormat.format(item.currentPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Hiển thị giá gốc nếu có giảm giá
                    // if (product.salePrice < product.regularPrice)
                    //   Text(
                    //     currencyFormat.format(product.regularPrice),
                    //     style: const TextStyle(
                    //       decoration: TextDecoration.lineThrough,
                    //       color: Colors.grey,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          ),

          // Số lượng
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 30), // Căn chỉnh với giá
              Text(
                'x${item.quantity}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
