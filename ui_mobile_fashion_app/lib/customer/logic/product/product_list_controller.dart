// lib/customer/logic/product/product_list_controller.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_data.dart';
import 'package:ui_mobile_fashion_app/customer/logic/product/product_api.dart';

class ProductListController extends ChangeNotifier {
  final String filter;

  List<ProductData> products = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? error;

  ProductListController({required this.filter}) {
    loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      final newProducts = await ProductApi.getList(
        filter: filter,
        limit: 10,
        page: _currentPage,
      );

      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        products.addAll(newProducts);
        _currentPage++;
      }
    } catch (e) {
      error = 'Không thể tải sản phẩm. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    products.clear();
    _currentPage = 1;
    _hasMore = true;
    error = null;
    notifyListeners();
    await loadMore();
  }

  bool shouldLoadMore(double pixels, double maxScroll) {
    return pixels >= maxScroll * 0.9 && !_isLoading && _hasMore;
  }

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
}