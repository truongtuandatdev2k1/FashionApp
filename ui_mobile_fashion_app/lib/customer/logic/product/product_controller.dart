// lib/customer/logic/product/product_controller.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_data.dart'; // ĐÃ SỬA
import 'product_api.dart';

class ProductController extends ChangeNotifier {
  List<ProductData> bestSellers = [];     // ĐÃ SỬA: ProductModel → ProductData
  List<ProductData> newArrivals = [];     // ĐÃ SỬA
  List<ProductData> hotTrends = [];       // ĐÃ SỬA

  bool isLoadingBest = false;
  bool isLoadingNew = false;
  bool isLoadingHot = false;

  String? errorBest;
  String? errorNew;
  String? errorHot;

  Future<void> fetchBestSellers() async {
    isLoadingBest = true;
    errorBest = null;
    notifyListeners();

    try {
      bestSellers = await ProductApi.getList(filter: 'bestseller');
    } catch (e) {
      errorBest = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingBest = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewArrivals() async {
    isLoadingNew = true;
    errorNew = null;
    notifyListeners();

    try {
      newArrivals = await ProductApi.getList(filter: 'new');
    } catch (e) {
      errorNew = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingNew = false;
      notifyListeners();
    }
  }

  Future<void> fetchHotTrends() async {
    isLoadingHot = true;
    errorHot = null;
    notifyListeners();

    try {
      hotTrends = await ProductApi.getList(filter: 'hottrend');
    } catch (e) {
      errorHot = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingHot = false;
      notifyListeners();
    }
  }
}