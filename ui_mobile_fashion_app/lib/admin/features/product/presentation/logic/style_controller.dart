// lib/admin/features/product/presentation/logic/style_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';

class Style {
  final int id;
  final String name;
  final String displayName; // Tên hiển thị tiếng Việt (đã đẹp sẵn từ API)

  Style({required this.id, required this.name, required this.displayName});

  factory Style.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] as String;
    // API đã trả về tên tiếng Việt đẹp rồi, nên displayName = name
    return Style(
      id: json['id'] as int,
      name: name,
      displayName: name, // Không cần map lại vì đã là "Thường ngày", "Đường phố",...
    );
  }
}

class StyleController extends ChangeNotifier {
  List<Style> _styles = [];
  bool _isLoading = false;
  String? _error;

  List<Style> get styles => _styles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStyles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/styles'),
        headers: {
          'Content-Type': 'application/json',
          // Nếu cần token: 'Authorization': 'Bearer ${token}',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['code'] == 'OK') {
          final List<dynamic> data = jsonData['data'];
          _styles = data.map((item) => Style.fromJson(item)).toList();
        } else {
          _error = 'Dữ liệu không hợp lệ từ máy chủ';
        }
      } else {
        _error = 'Lỗi kết nối: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Không thể tải danh sách phong cách. Vui lòng kiểm tra mạng.';
    }

    _isLoading = false;
    notifyListeners();
  }
}