// lib/admin/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_mobile_fashion_app/admin/features/auth/presentation/logic/admin_login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Controller xử lý logic đăng nhập (tách riêng)
  final AdminLoginController _loginController = AdminLoginController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String? error = await _loginController.login(
      credential: emailController.text.trim(),
      password: passwordController.text,
    );

    if (mounted) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });

      // Nếu đăng nhập thành công → chuyển hướng
      if (error == null) {
        context.go('/dashboard');
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 70,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FASHION ADMIN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng đăng nhập để quản lý hệ thống',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Ô nhập Email
                    _buildTextField(
                      controller: emailController,
                      label: 'Email quản trị',
                      icon: Icons.email_outlined,
                      validator:
                          (value) =>
                              value?.trim().isEmpty ?? true
                                  ? 'Vui lòng nhập email'
                                  : null,
                    ),
                    const SizedBox(height: 20),

                    // Ô nhập Mật khẩu
                    _buildTextField(
                      controller: passwordController,
                      label: 'Mật khẩu',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Vui lòng nhập mật khẩu'
                                  : null,
                    ),
                    const SizedBox(height: 12),

                    // Hiển thị lỗi (nếu có)
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {}, // Có thể thêm chức năng quên mật khẩu sau
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nút Đăng nhập
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'ĐĂNG NHẬP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '© 2025 Fashion App Management',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget TextFormField đã được tối ưu cho Flutter Web
  /// - Fix lag khi gõ mật khẩu
  /// - Fix hiện ký tự thừa khi xóa hết
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      autocorrect: !isPassword, // Tắt sửa lỗi chính tả cho mật khẩu
      enableSuggestions: !isPassword, // Tắt gợi ý (rất quan trọng trên Web)
      autofocus: false, // Tránh conflict focus với trình duyệt
      enableInteractiveSelection: true, // Đảm bảo chọn văn bản tốt hơn trên Web
      validator: validator,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
