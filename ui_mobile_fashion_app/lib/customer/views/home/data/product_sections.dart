// lib/customer/views/home/data/product_sections.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_api.dart';
import '../widgets/horizontal_product_section.dart';

// KHAI BÁO FILTER → TỰ ĐỘNG GỌI API
final List<Future<Widget>> homeProductSections = [
  _buildSection('Bán chạy nhất', 'bestseller'),
  // _buildSection('Sản phẩm mới', 'new'),
  _buildSection('Hot trend', 'hottrend'),
];

Future<Widget> _buildSection(String title, String filter) async {
  final products = await ProductApi.getList(
    filter: filter,
  ); // Trả về List<ProductData>
  return HorizontalProductSection(
    title: title,
    products: products, // ĐÚNG KIỂU
  );
}
