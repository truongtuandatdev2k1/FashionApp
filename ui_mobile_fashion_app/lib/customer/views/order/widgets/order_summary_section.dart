// lib/customer/views/order/widgets/order_summary_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSummarySection extends StatelessWidget {
  final double subtotal;
  final int totalItems;

  const OrderSummarySection({
    super.key,
    required this.subtotal,
    required this.totalItems,
  });

  static const double shippingFee = 1000;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final double total = subtotal + shippingFee;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Delivery Guarantee ---
          const Text(
            'Đảm bảo giao hàng: 25-26/3',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Row(
            children: <Widget>[
              Icon(Icons.local_shipping_outlined, color: Colors.black87, size: 20),
              SizedBox(width: 8),
              Text('Vận chuyển tiêu chuẩn', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhận voucher giảm giá nếu được đơn hàng bị giao muộn',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 20),
          const Divider(height: 8, thickness: 8, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // --- Order Summary ---
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildRow('Tổng phụ ($totalItems sp)', currency.format(subtotal)),
          _buildRow('Vận chuyển', currency.format(shippingFee)),
          const Divider(color: Color(0xFFEEEEEE)),
          _buildRow('Tổng', currency.format(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}