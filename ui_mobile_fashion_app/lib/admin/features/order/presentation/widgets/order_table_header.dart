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
        children: const [
          SizedBox(width: 60, child: _HeaderText('STT')),
          SizedBox(width: 200, child: _HeaderText('Mã đơn')),
          SizedBox(width: 160, child: _HeaderText('SĐT')),
          SizedBox(width: 120, child: _HeaderText('Giờ đặt')),
          SizedBox(width: 140, child: _HeaderText('Ngày đặt')),
          SizedBox(width: 200, child: _HeaderText('Trạng thái')),
          SizedBox(width: 180, child: _HeaderText('Tổng tiền')),
          SizedBox(width: 100, child: Center(child: _HeaderText('Thao tác'))),
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