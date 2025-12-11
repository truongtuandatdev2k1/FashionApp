// lib/customer/views/auth/complete_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/customer/logic/profile/update_profile_api.dart'; // Import mới

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await UpdateProfileApi.updateProfile(
        fullName: _fullNameController.text.trim(),
        age: _ageController.text.trim(),
        address: _addressController.text.trim(),
        avatarFile: _avatarImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật hồ sơ thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => context.go('/register'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Hoàn thiện hồ sơ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Giúp chúng tôi hiểu bạn hơn',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 40),

              // Ảnh đại diện
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _pickAvatar,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        _avatarImage != null ? FileImage(_avatarImage!) : null,
                    child:
                        _avatarImage == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.camera,
                                  size: 40,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thêm ảnh',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                            : null,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Họ và tên
              _buildLabel('Họ và tên'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration(
                  'Nhập họ và tên của bạn',
                  LucideIcons.user,
                ),
                validator:
                    (v) =>
                        v?.trim().isEmpty ?? true
                            ? 'Vui lòng nhập họ tên'
                            : null,
              ),

              const SizedBox(height: 20),
              _buildLabel('Tuổi'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  'Nhập tuổi của bạn',
                  LucideIcons.cake,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập tuổi';
                  final age = int.tryParse(v);
                  if (age == null || age < 10 || age > 120)
                    return 'Tuổi không hợp lệ';
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _buildLabel('Địa chỉ'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                maxLines: 1,
                decoration: _inputDecoration(
                  'Nhập địa chỉ nhận hàng',
                  LucideIcons.mapPin,
                ),
                validator:
                    (v) =>
                        v?.trim().isEmpty ?? true
                            ? 'Vui lòng nhập địa chỉ'
                            : null,
              ),

              const SizedBox(height: 50),

              // Nút Hoàn thành
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                          'Hoàn thành',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xff757575)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
