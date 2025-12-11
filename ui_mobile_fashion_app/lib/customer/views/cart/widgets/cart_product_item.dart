// lib/customer/views/cart/widgets/cart_product_item.dart file gốc

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../logic/cart/cart_api.dart';
import '../../../logic/cart/delete_item_api.dart';

class CartProductItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onUpdate;

  const CartProductItem({Key? key, required this.item, required this.onUpdate})
    : super(key: key);

  Future<void> _deleteItem(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Hiển thị loading
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Đang xóa...'),
          ],
        ),
      ),
    );

    try {
      await DeleteItemApi.deleteCartItem(item.id);

      if (!context.mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      onUpdate(); // Refresh giỏ hàng
    } catch (e) {
      if (!context.mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final product = item.product;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.fullImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),

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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Màu: ${product.color} • Size: ${product.size}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              // TODO: giảm số lượng (sẽ làm sau)
                            },
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              // TODO: tăng số lượng
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nút xóa (gọi API thật)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => _deleteItem(context),
            ),
          ],
        ),
      ),
    );
  }
}
