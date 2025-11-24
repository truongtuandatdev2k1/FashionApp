// lib/customer/views/address/views/address_list_screen.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/mock_address_data.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/views/address_form_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/empty_address_view.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/address_list_view.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addresses = MockAddressData.getAddresses();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Địa Chỉ Nhận Hàng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: addresses.isEmpty
          ? const EmptyAddressView()
          : AddressListView(addresses: addresses, onAddNew: () {}),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressFormScreen()),
          );
        },
      ),
    );
  }
}