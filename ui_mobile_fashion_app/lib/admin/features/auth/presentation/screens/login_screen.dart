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

  // Controller xử lý logic đăng nhập
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

      if (error == null) {
        context.go('/orders');
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
    // Mã màu nền F2F3F4
    const backgroundColor = Color(0xFFF2F3F4);

    return Scaffold(
      backgroundColor: backgroundColor, // Đặt màu nền cho Scaffold
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thay thế Icon bằng Logo ảnh
                  Image.asset(
                    'assets/logo_fas.png',
                    height: 40, // Chiều cao logo tùy chỉnh cho cân đối
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'FASHION ADMIN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black, // Chuyển sang màu đen
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng đăng nhập để quản lý hệ thống',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

                  // Hiển thị lỗi
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: _isLoading ? null : () {},
                  //     style: TextButton.styleFrom(
                  //       foregroundColor: Colors.grey.shade700,
                  //     ),
                  //     child: const Text('Quên mật khẩu?'),
                  //   ),
                  // ),
                  const SizedBox(height: 30),

                  // Nút Đăng nhập
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Màu nút chuyển sang Đen
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0, // Bỏ đổ bóng nút cho phẳng
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    // Màu viền mặc định
    const borderColor = Color(0xFFD9D9D9);

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      autocorrect: !isPassword,
      enableSuggestions: !isPassword,
      autofocus: false,
      enableInteractiveSelection: true,
      validator: validator,
      enabled: !_isLoading,
      cursorColor: Colors.black, // Màu con trỏ
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // Khi focus chuyển sang màu đen thay vì xanh
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white, // Nền input trắng
      ),
    );
  }
}
