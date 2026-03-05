// file: lib/customer/views/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';

import '../../logic/auth/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Dùng DUY NHẤT _emailController cho cả Autocomplete lẫn logic
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberAccount = false;

  static const _kRemember = 'remember_account';
  static const _kSavedAccounts = 'saved_accounts';

  List<String> _savedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRemember) ?? false;
    final accounts = prefs.getStringList(_kSavedAccounts) ?? [];

    if (!mounted) return;
    setState(() {
      _rememberAccount = remember;
      _savedAccounts = accounts;
    });

    // Tự điền tài khoản đầu tiên nếu đang bật nhớ
    if (remember && accounts.isNotEmpty) {
      final parts = accounts.first.split('||');
      if (parts.length == 2) {
        _emailController.text = parts[0];
        _passwordController.text = parts[1];
      }
    }
  }

  Future<void> _saveAccount(String credential, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_kSavedAccounts) ?? [];
    final entry = '$credential||$password';
    accounts.removeWhere((a) => a.split('||').first == credential);
    accounts.insert(0, entry);
    await prefs.setStringList(_kSavedAccounts, accounts);
    if (mounted) setState(() => _savedAccounts = accounts);
  }

  Future<void> _removeAccount(String credential) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_kSavedAccounts) ?? [];
    accounts.removeWhere((a) => a.split('||').first == credential);
    await prefs.setStringList(_kSavedAccounts, accounts);
    if (mounted) setState(() => _savedAccounts = accounts);
  }

  /// Điền thông tin khi chọn gợi ý
  /// Dùng addPostFrameCallback để tránh set controller trong build phase
  void _fillAccount(String credential) {
    final entry = _savedAccounts.firstWhere(
          (a) => a.split('||').first == credential,
      orElse: () => '',
    );
    if (entry.isEmpty) return;
    final parts = entry.split('||');
    if (parts.length == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _emailController.text = parts[0];
        _passwordController.text = parts[1];
        setState(() => _rememberAccount = true);
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final credential = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await CustomerAuthApi.login(credential, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRemember, _rememberAccount);
      if (_rememberAccount) {
        await _saveAccount(credential, password);
      }

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _credentialList =>
      _savedAccounts.map((a) => a.split('||').first).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Assets.logoFas.image(
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Đăng Nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // ── Tài khoản ──────────────────────────────────────────────
              const Text(
                'Tài khoản',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty || _credentialList.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _credentialList.where(
                        (c) => c.toLowerCase().contains(value.text.toLowerCase()),
                  );
                },
                onSelected: (String selected) {
                  _fillAccount(selected);
                },
                fieldViewBuilder: (
                    BuildContext ctx,
                    TextEditingController fieldController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                    ) {
                  return TextFormField(
                    controller: fieldController,
                    focusNode: focusNode,
                    // ✅ Sync một chiều qua onChanged - KHÔNG set .text trong build
                    onChanged: (val) {
                      if (_emailController.text != val) {
                        _emailController.text = val;
                        _emailController.selection = TextSelection.fromPosition(
                          TextPosition(offset: val.length),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Email/số điện thoại của bạn',
                      prefixIcon: const Icon(
                        LucideIcons.user,
                        size: 20,
                        color: Color(0xff757575),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 14.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value?.trim().isEmpty ?? true
                        ? 'Vui lòng nhập tài khoản'
                        : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              leading: const Icon(
                                LucideIcons.user,
                                size: 18,
                                color: Color(0xff757575),
                              ),
                              title: Text(
                                option,
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                tooltip: 'Xoá tài khoản đã lưu',
                                onPressed: () => _removeAccount(option),
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Mật khẩu ───────────────────────────────────────────────
              const Text(
                'Mật khẩu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu của bạn',
                  prefixIcon: const Icon(
                    LucideIcons.lock,
                    size: 20,
                    color: Color(0xff757575),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 14.0,
                  ),
                ),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Vui lòng nhập mật khẩu' : null,
              ),
              const SizedBox(height: 12),

              // ── Checkbox Nhớ tài khoản ─────────────────────────────────
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberAccount,
                      onChanged: (val) =>
                          setState(() => _rememberAccount = val ?? false),
                      activeColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.black38, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _rememberAccount = !_rememberAccount),
                    child: const Text(
                      'Nhớ tài khoản',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // ── Nút Đăng Nhập ──────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Đăng Nhập',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // ── Đăng ký ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tôi chưa có tài khoản? ',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}