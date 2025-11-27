// lib/customer/views/address/widgets/address_list_view.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/address_item.dart';

class AddressListView extends StatelessWidget {
  final List<Map<String, dynamic>> addresses;
  final VoidCallback onAddNew;

  const AddressListView({
    Key? key,
    required this.addresses,
    required this.onAddNew,
  }) : super(key: key);

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
            name: addr['name'] as String,
            phone: addr['phone'] as String,
            address: addr['address'] as String,
            isDefault: addr['isDefault'] as bool,
            onEdit: () {
              // TODO: mở form sửa
            },
          ),
        );
      },
    );
  }
}