// lib/customer/views/address/widgets/empty_address_view.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmptyAddressView extends StatelessWidget {
  const EmptyAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.mapPin, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            "Bạn chưa có địa chỉ nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "Nhấn nút + để thêm địa chỉ mới",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}