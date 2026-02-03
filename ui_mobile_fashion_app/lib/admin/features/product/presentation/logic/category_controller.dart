// lib/admin/features/product/presentation/logic/category_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';

class Category {
  final int id;
  final String name;
  final String displayName; // Thêm để hiển thị tiếng Việt

  Category({required this.id, required this.name, required this.displayName});

  factory Category.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] as String;

    // Map tên tiếng Anh → tiếng Việt đẹp trên UI
    final Map<String, String> vietnameseNames = {
      'shirt': 'Áo',
      'trousers': 'Quần',
      'set': 'Bộ',
      'dress': 'Váy',
      'accessories': 'Phụ kiện',
      'jacket': 'Áo khoác',
      'hoodie': 'Áo hoodie',
      't-shirt': 'Áo thun',
      'shorts': 'Quần short',
      // Thêm sau nếu có
    };

    return Category(
      id: json['id'] as int,
      name: name,
      displayName: vietnameseNames[name] ?? name[0].toUpperCase() + name.substring(1), // fallback
    );
  }
}

class CategoryController extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['code'] == 'OK') {
          final List<dynamic> data = jsonData['data'];
          _categories = data.map((item) => Category.fromJson(item)).toList();
        } else {
          _error = 'Dữ liệu không hợp lệ từ máy chủ';
        }
      } else {
        _error = 'Lỗi kết nối: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Không thể tải danh mục. Vui lòng kiểm tra mạng.';
    }

    _isLoading = false;
    notifyListeners();
  }
}