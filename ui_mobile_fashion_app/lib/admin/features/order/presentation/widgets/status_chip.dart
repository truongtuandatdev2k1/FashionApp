// lib/admin/features/order/presentation/widgets/status_chip.dart
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Hoàn thành':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'Đang giao':
        color = Colors.blue;
        icon = Icons.local_shipping_outlined;
        break;
      case 'Đã hủy':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case 'Chờ xác nhận':
        color = Colors.orange;
        icon = Icons.hourglass_empty_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
