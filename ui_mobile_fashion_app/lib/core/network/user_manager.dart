// lib/core/network/user_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static Future<void> saveUser({
    required int id,
    required String role,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('user_role', role);
    await prefs.setString('user_name', name);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id == null) return null;
    return {
      'id': id,
      'role': prefs.getString('user_role'),
      'name': prefs.getString('user_name'),
    };
  }
}