// lib/customer/logic/adress/mock_address_data.dart

class MockAddressData {
  // BẬT/TẮT TOÀN BỘ MOCK DATA TẠI ĐÂY
  static const bool enabled = true;

  static final List<Map<String, dynamic>> addresses = [
    {
      "id": "1",
      "name": "Nguyễn Văn A",
      "phone": "0901234567",
      "address": "123 Đường Láng, P. Láng Thượng, Q. Đống Đa, Hà Nội",
      "isDefault": true,
    },
    {
      "id": "2",
      "name": "Trần Thị Bích",
      "phone": "0987654321",
      "address": "456 Lê Văn Sỹ, P.14, Q.3, TP. Hồ Chí Minh",
      "isDefault": false,
    },
    {
      "id": "3",
      "name": "Lê Văn Cường",
      "phone": "0938123456",
      "address": "789 Nguyễn Trãi, P. Thanh Xuân Trung, Q. Thanh Xuân, Hà Nội",
      "isDefault": false,
    },
  ];

  static List<Map<String, dynamic>> getAddresses() {
    return enabled ? addresses : [];
  }
}