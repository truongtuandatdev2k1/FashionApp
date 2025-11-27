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
        // Thêm nút back thủ công ở bên trái
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Địa Chỉ Nhận Hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Nếu muốn bỏ luôn back button tự động của hệ thống (tránh bị trùng)
        // automaticallyImplyLeading: false,
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