// lib/customer/views/order/widgets/order_payment_method_section.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';

class OrderPaymentMethodSection extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const OrderPaymentMethodSection({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildOption(
            icon: Icons.wallet_outlined,
            label: 'Thanh toán khi nhận hàng',
            value: 'cod',
          ),
          _buildOption(
            leading: Assets.customer.images.vnpay.image(
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            label: 'Thanh toán online qua PayOS',
            value: 'bank_transfer',
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    Widget? leading,
    IconData? icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading ?? Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Radio<String>(
        value: value,
        groupValue: selectedMethod,
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
        activeColor: Colors.black,
      ),
      onTap: () => onChanged(value),
    );
  }
}