// lib/customer/views/order/widgets/order_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderBottomBar extends StatelessWidget {
  final double subtotal;
  final int totalItems;
  final VoidCallback onPlaceOrder;

  static const double shippingFee = 1000;

  const OrderBottomBar({
    super.key,
    required this.subtotal,
    required this.totalItems,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final double total = subtotal + shippingFee;

    return Container(
      height: 70,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Tổng ($totalItems mặt hàng)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                currency.format(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              'Đặt hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}