// lib/customer/views/home/data/product_sections.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_api.dart';
import '../widgets/horizontal_product_section.dart';

// ❌ CÁCH CŨ - Chỉ gọi API 1 lần duy nhất khi app khởi động
// final List<Future<Widget>> homeProductSections = [
//   _buildSection('Bán chạy nhất', 'bestseller'),
//   _buildSection('Hot trend', 'hottrend'),
// ];

// ✅ CÁCH MỚI - Tạo hàm trả về Future mới mỗi lần gọi
List<Future<Widget>> getHomeProductSections() {
  print('🔄 Đang tạo sections mới - gọi API...');
  return [
    _buildSection('Bán chạy nhất', 'bestseller'),
    _buildSection('Hot trend', 'hottrend'),
    // _buildSection('Sản phẩm mới', 'new'),
  ];
}

Future<Widget> _buildSection(String title, String filter) async {
  print('📡 Đang fetch API cho: $title (filter: $filter)');
  final products = await ProductApi.getList(
    filter: filter,
  ); // Trả về List<ProductData>

  print('✅ Đã load ${products.length} sản phẩm cho: $title');

  return HorizontalProductSection(
    title: title,
    products: products,
  );
}