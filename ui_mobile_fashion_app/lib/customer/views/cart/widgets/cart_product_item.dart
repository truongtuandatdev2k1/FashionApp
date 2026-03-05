import 'package:flutter/material.dart';

import '../../../logic/cart/cart_api.dart';
import '../../../logic/cart/delete_item_api.dart';
import 'cart_product_item_ui.dart'; // ← import file UI mới

class CartProductItem extends StatefulWidget {
  final CartItem item;
  final VoidCallback onUpdate;
  final ValueChanged<bool> onSelectionChanged;
  final bool isSelected; // ← THÊM

  const CartProductItem({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onSelectionChanged,
    required this.isSelected, // ← THÊM
  });

  @override
  State<CartProductItem> createState() => _CartProductItemState();
}

class _CartProductItemState extends State<CartProductItem> {
  // Bỏ _isSelected local, dùng widget.isSelected từ ngoài truyền vào

  Future<void> _deleteItem(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Đang xóa...'),
          ],
        ),
        duration: Duration(seconds: 8),
      ),
    );

    try {
      await DeleteItemApi.deleteCartItem(widget.item.id);

      if (!context.mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      widget.onUpdate();
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
    return Dismissible(
      key: ValueKey(widget.item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade600,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 36,
        ),
      ),
      confirmDismiss: (direction) async {
        return true;
      },
      onDismissed: (direction) {
        _deleteItem(context);
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            CartProductItemUI(
              item: widget.item,
              isSelected: widget.isSelected, // ← dùng từ parent
              onSelectionChanged: (value) {
                widget.onSelectionChanged(value);
              },
            ),
            const SizedBox(height: 5),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE8E8E8),
            ),
            // const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}