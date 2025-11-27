// lib/customer/views/address/widgets/address_item.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddressItem extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final bool isDefault;
  final VoidCallback onEdit;

  const AddressItem({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDefault ? Colors.black : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("Mặc định", style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(phone, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text(address, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.pencil, size: 20),
                onPressed: onEdit,
                ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                onPressed: () {
                  // TODO: Xóa địa chỉ
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}