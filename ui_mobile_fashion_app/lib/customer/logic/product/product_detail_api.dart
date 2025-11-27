// lib/customer/logic/product/product_detail_api.dart
import 'package:ui_mobile_fashion_app/core/network/api_config.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_detail_model.dart';

class ProductDetailApi {
  static final _dio = ApiConfig.dio;

  static Future<ProductDetailModel> getProduct(int id) async {
    final response = await _dio.get('/products/$id');
    if (response.data['code'] == 'OK') {
      final baseUrl = ApiConfig.dio.options.baseUrl.replaceAll('/api/v1', '');
      return ProductDetailModel.fromJson(response.data, baseUrl);
    }
    throw Exception('Không tải được chi tiết sản phẩm');
  }
}
