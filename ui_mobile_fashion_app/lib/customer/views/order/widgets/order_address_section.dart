// lib/customer/views/order/widgets/order_address_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ***************************************************************
// IMPORT MODEL VÀ API
import 'package:ui_mobile_fashion_app/customer/models/address.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_default_api.dart';
// ***************************************************************

class OrderAddressSection extends StatefulWidget {
  const OrderAddressSection({super.key});

  @override
  State<OrderAddressSection> createState() => _OrderAddressSectionState();
}

class _OrderAddressSectionState extends State<OrderAddressSection> {
  late Future<Address?> _defaultAddressFuture;

  @override
  void initState() {
    super.initState();
    _defaultAddressFuture = AddressDefaultApi.getDefaultAddress();
  }

  // Helper function để format số điện thoại: 0900555000 -> (+84)090********00
  String _formatPhoneNumber(String number) {
    if (number.length < 10) return number;
    final prefix = number.substring(0, 3);
    final suffix = number.substring(number.length - 2);
    return '(+84)$prefix********$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Address?>(
      future: _defaultAddressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị loading state (Skeleton loader hoặc Placeholder)
          return _buildLoadingState();
        }

        final Address? address = snapshot.data;

        // Dùng địa chỉ mặc định nếu có, nếu không thì dùng placeholder/báo lỗi
        if (address == null) {
          return _buildEmptyState();
        }

        // --- Giao diện hiển thị địa chỉ thực tế ---
        final formattedPhone = _formatPhoneNumber(address.phoneNumber);

        return InkWell(
          onTap: () {
            // Chuyển hướng đến màn hình danh sách địa chỉ
            context.push('/addresses');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.location_on_outlined, color: Colors.black87),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${address.recipientName} $formattedPhone',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị khi đang tải
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.location_on_outlined, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                LinearProgressIndicator(color: Colors.grey),
                SizedBox(height: 8),
                LinearProgressIndicator(color: Colors.grey, value: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị khi không có địa chỉ mặc định
  Widget _buildEmptyState() {
    return InkWell(
      onTap: () {
        context.push('/addresses');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: const [
            Icon(Icons.location_off_outlined, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Vui lòng thêm hoặc chọn địa chỉ giao hàng mặc định.',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
            Icon(Icons.add, size: 18, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
