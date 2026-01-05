// lib/customer/views/address/views/address_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Đảm bảo có dòng này
import 'package:ui_mobile_fashion_app/customer/logic/address/address_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/empty_address_view.dart';
import 'package:ui_mobile_fashion_app/customer/views/address/widgets/address_list_view.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final ValueNotifier<List<Address>> _addressesNotifier = ValueNotifier([]);
  bool _isInitialLoading = true;

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
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
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
        // Sử dụng GoRouter.of(context).canPop() để an toàn tuyệt đối
        leading:
            GoRouter.of(context).canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => context.pop(),
                )
                : null,
        title: const Text(
          "Địa Chỉ Nhận Hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: _addressesNotifier,
        builder: (context, addresses, _) {
          if (_isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (addresses.isEmpty) {
            return const EmptyAddressView();
          }
          return AddressListView(
            addresses: addresses,
            onRefresh: _loadAddresses,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Sử dụng context.push<T> để chỉ định kiểu dữ liệu trả về là bool
          final result = await context.push<bool>('/profile/addresses/add');

          if (result == true && mounted) {
            _loadAddresses();
          }
        },
      ),
    );
  }
}
