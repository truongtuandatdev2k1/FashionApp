// lib/customer/views/common/navigation_helper.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_detail_screen.dart';

/// Tập hợp các hàm điều hướng dùng chung cho toàn bộ customer app.
/// Dùng [Navigator.push] + [MaterialPageRoute] để đồng nhất với cách
/// các màn hình khác (home, saved, ...) đang navigate.
class NavigationHelper {
  NavigationHelper._(); // Không cho khởi tạo instance

  /// Điều hướng đến màn hình chi tiết sản phẩm.
  ///
  /// Dùng ở bất kỳ nơi nào có [productId]:
  /// ```dart
  /// NavigationHelper.toProductDetail(context, productId: product.id);
  /// ```
  static void toProductDetail(
      BuildContext context, {
        required int productId,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }
}