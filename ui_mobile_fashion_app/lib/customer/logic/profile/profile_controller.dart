// lib/customer/logic/profile/profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'profile_api.dart';
import 'update_profile_api.dart';

class ProfileController extends ChangeNotifier {
  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? error;

  bool isUpdating = false;
  String? updateError;

  // ─── FETCH ───────────────────────────────────────────────────────────────────
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

  // ─── UPDATE ──────────────────────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String fullName,
    required String age,
    required String address,
    required String gender,
    File? avatarFile,
  }) async {
    isUpdating = true;
    updateError = null;
    notifyListeners();

    try {
      final newData = await UpdateProfileApi.updateProfile(
        fullName: fullName,
        age: age,
        address: address,
        gender: gender,
        avatarFile: avatarFile,
      );

      // Ưu tiên data server trả về, fallback tự patch local
      if (newData.isNotEmpty) {
        userData = newData;
      } else {
        userData = {
          ...?userData,
          'FullName': fullName,
          'Age': int.tryParse(age),
          'Address': address,
          'Gender': gender,
        };
      }

      return true;
    } catch (e) {
      updateError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}