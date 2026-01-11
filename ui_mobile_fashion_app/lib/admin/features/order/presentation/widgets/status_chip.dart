// lib/admin/features/order/presentation/widgets/status_chip.dart
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isDropdown; // Thêm thuộc tính này

  const StatusChip({
    super.key,
    required this.status,
    this.isDropdown = false, // Mặc định là false
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String labelText;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty_outlined;
        labelText = 'Chờ xác nhận';
        break;
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        labelText = 'Đã xác nhận';
        break;
      case 'shipping':
        color = Colors.blue;
        icon = Icons.local_shipping_outlined;
        labelText = 'Đang giao';
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.task_alt;
        labelText = 'Hoàn thành';
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        labelText = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        labelText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            labelText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Nếu là dropdown thì hiện thêm mũi tên trỏ xuống 'v'
          if (isDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 18, color: color),
          ],
        ],
      ),
    );
  }
}