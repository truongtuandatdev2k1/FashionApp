// lib/customer/views/address/widgets/address_item.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';

class AddressItem extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressItem({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === Nội dung item ===
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          color: Colors.white, // nền trắng sạch
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Thông tin địa chỉ ===
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên người nhận
                    Text(
                      address.recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Số điện thoại
                    Text(
                      address.phoneNumber,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    // Địa chỉ đầy đủ
                    Text(
                      address.fullAddress,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    // Tag "Mặc định" – chỉ hiện nếu là mặc định
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8), // xanh lá nhạt
                          border: Border.all(color: const Color(0xFF4CAF50)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Mặc định",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // === Nút sửa + xóa ===
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
        ),

        // === Đường kẻ phân cách mảnh (trừ item cuối cùng sẽ được ListView xử lý) ===
        const Divider(
          height: 1,
          thickness: 0.5,
          color: Color(0xFFE0E0E0),
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
