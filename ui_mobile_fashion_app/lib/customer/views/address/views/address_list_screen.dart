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
  // Dùng ValueNotifier thay vì FutureBuilder + setState → KHÔNG BAO GIỜ BỊ LOCKED
  final ValueNotifier<List<Address>> _addressesNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await AddressApi.getAddresses();
      if (mounted) {
        _addressesNotifier.value = addresses;
      }
    } catch (e) {
      if (mounted) {
        _addressesNotifier.value = [];
      }
    }
  }

  @override
  void dispose() {
    _addressesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: _addressesNotifier,
        builder: (context, addresses, _) {
          // Loading đầu tiên
          if (addresses.isEmpty && _addressesNotifier.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (addresses.isEmpty) {
            return const EmptyAddressView();
          }

          return AddressListView(
            addresses: addresses,
            onRefresh: _loadAddresses, // refresh khi xóa/sửa
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // QUAN TRỌNG: KHÔNG gọi setState hay refresh ở đây
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressFormScreen()),
          );

          // Chỉ refresh nếu thêm/sửa thành công và widget còn sống
          if (result == true && mounted) {
            _loadAddresses();
          }
        },
      ),
    );
  }
}
