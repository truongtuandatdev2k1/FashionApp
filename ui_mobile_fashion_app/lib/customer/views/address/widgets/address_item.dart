// lib/customer/views/address/widgets/address_item.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_service.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';

class AddressItem extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onRefresh;

  const AddressItem({
    Key? key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onRefresh,
  }) : super(key: key);

  Future<void> _setDefault(BuildContext context) async {
    final success = await AddressService.setDefaultAddress(address.id);
    if (success && context.mounted) {
      onRefresh?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã đặt làm địa chỉ mặc định")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? Colors.black : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                    Text(
                      address.recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Mặc định",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: address.addressTypeColor.withOpacity(0.1),
                        border: Border.all(color: address.addressTypeColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        address.addressTypeLabel,
                        style: TextStyle(
                          color: address.addressTypeColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.phoneNumber,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(address.fullAddress, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                if (!address.isDefault)
                  GestureDetector(
                    onTap: () => _setDefault(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Đặt làm mặc định",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
