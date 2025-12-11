// lib/customer/views/address/widgets/address_list_view.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_service.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/views/address_form_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/address_item.dart';

class AddressListView extends StatelessWidget {
  final List<Address> addresses;
  final VoidCallback? onRefresh;

  const AddressListView({super.key, required this.addresses, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final addr = addresses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AddressItem(
            address: addr,
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddressFormScreen(address: addr),
                ),
              );
              if (result == true) onRefresh?.call();
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Xóa địa chỉ?"),
                      content: const Text("Bạn có chắc chắn muốn xóa?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Hủy"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Xóa",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                final success = await AddressService.deleteAddress(addr.id);
                if (success) onRefresh?.call();
              }
            },
            // onRefresh: onRefresh,
          ),
        );
      },
    );
  }
}
