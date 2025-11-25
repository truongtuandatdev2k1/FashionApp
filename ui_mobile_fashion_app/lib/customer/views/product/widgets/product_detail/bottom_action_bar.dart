// lib/customer/views/product/widgets/product_detail/bottom_action_bar.dart
import 'package:flutter/material.dart';
import 'size_color_selector_sheet.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  void _showSelectorSheet(BuildContext context, {required bool isBuyNow}) {
    SizeColorSelectorSheet.show(
      context,
      isBuyNow: isBuyNow,
      onConfirm: () {
        final message = isBuyNow
            ? 'Đã chọn "Mua ngay" thành công!'
            : 'Đã thêm vào giỏ hàng thành công!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // TODO: Gọi API add to cart / navigate to checkout ở đây
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 30),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showSelectorSheet(context, isBuyNow: false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Add Cart',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showSelectorSheet(context, isBuyNow: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0079C2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}