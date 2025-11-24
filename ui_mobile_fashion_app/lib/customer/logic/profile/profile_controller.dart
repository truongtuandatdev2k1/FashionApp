// lib/customer/logic/profile/profile_controller.dart
import 'package:flutter/material.dart';
import 'profile_api.dart';

class ProfileController extends ChangeNotifier {
  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? error;

  Future<void> fetchProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      userData = await ProfileApi.getMe();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}