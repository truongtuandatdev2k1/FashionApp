// lib/customer/views/address/views/address_list_screen.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/views/address_form_screen.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/empty_address_view.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/address_list_view.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late Future<List<Address>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = AddressApi.getAddresses();
  }

  void _refresh() {
    setState(() {
      _addressesFuture = AddressApi.getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Địa Chỉ Nhận Hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Address>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return const EmptyAddressView();
          }

          return AddressListView(addresses: addresses, onRefresh: _refresh);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressFormScreen()),
          );
          if (result == true) _refresh();
        },
      ),
    );
  }
}
