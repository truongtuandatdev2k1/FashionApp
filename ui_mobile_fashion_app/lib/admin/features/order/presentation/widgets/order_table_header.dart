// lib/admin/features/order/presentation/widgets/order_table_header.dart
import 'package:flutter/material.dart';

class OrderTableHeader extends StatelessWidget {
  final double width;

  const OrderTableHeader({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 60, child: _HeaderText('STT')),
          const SizedBox(width: 140, child: _HeaderText('Mã đơn')),
          const Expanded(child: _HeaderText('Khách hàng')),
          const SizedBox(width: 160, child: _HeaderText('SĐT')),
          const SizedBox(width: 120, child: _HeaderText('Giờ đặt')),
          const SizedBox(width: 140, child: _HeaderText('Ngày đặt')),
          const SizedBox(width: 80, child: Center(child: _HeaderText('SL'))),
          const SizedBox(width: 200, child: _HeaderText('Trạng thái')),
          const SizedBox(
            width: 100,
            child: Center(child: _HeaderText('Thao tác')),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String label;

  const _HeaderText(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
