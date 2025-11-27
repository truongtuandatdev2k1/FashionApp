// lib/customer/models/address.dart
import 'package:flutter/material.dart';

class Address {
  final int id;
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final String addressType; // home, office, other...
  final bool isDefault;

  const Address({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.addressType,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      recipientName: json['recipient_name'] as String,
      phoneNumber: json['phone_number'] as String,
      fullAddress: json['full_address'] as String,
      addressType: json['address_type'] as String? ?? 'other',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  // Dùng để hiển thị tag (Nhà riêng / Công ty)
  String get addressTypeLabel {
    switch (addressType.toLowerCase()) {
      case 'home':
        return 'Nhà riêng';
      case 'office':
        return 'Công ty';
      default:
        return 'Khác';
    }
  }

  Color get addressTypeColor {
    switch (addressType.toLowerCase()) {
      case 'home':
        return Colors.green.shade600;
      case 'office':
        return Colors.blue.shade600;
      default:
        return Colors.orange.shade600;
    }
  }
}
