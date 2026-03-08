// lib/customer/views/profile/views/profile_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ui_mobile_fashion_app/core/utils/image_url_helper.dart';
import 'package:ui_mobile_fashion_app/customer/logic/profile/profile_controller.dart';

const Color kPrimaryColor = Colors.black;

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _addressCtrl;
  String _selectedGender = 'nam';
  File? _pickedAvatar;

  static const List<Map<String, String>> _genderOptions = [
    {'value': 'nam', 'label': 'Nam'},
    {'value': 'nu', 'label': 'Nữ'},
    {'value': 'khac', 'label': 'Khác'},
  ];

  @override
  void initState() {
    super.initState();
    final userData = context.read<ProfileController>().userData;
    _fullNameCtrl = TextEditingController(text: userData?['FullName'] ?? '');
    _ageCtrl = TextEditingController(
      text: userData?['Age'] != null ? '${userData!['Age']}' : '',
    );
    _addressCtrl = TextEditingController(text: userData?['Address'] ?? '');
    _selectedGender = userData?['Gender'] ?? 'nam';
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ─── PICK AVATAR ─────────────────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: kPrimaryColor),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: kPrimaryColor),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _pickedAvatar = File(file.path));
      }
    } catch (e) {
      _showSnack('Không thể chọn ảnh: $e', isError: true);
    }
  }

  // ─── SAVE ─────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ProfileController>();
    final success = await controller.updateProfile(
      fullName: _fullNameCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _selectedGender,
      avatarFile: _pickedAvatar,
    );

    if (!mounted) return;

    if (success) {
      _showSnack('Cập nhật thành công!');
      Navigator.pop(context);
    } else {
      _showSnack(controller.updateError ?? 'Cập nhật thất bại', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Dùng Selector để chỉ rebuild khi isUpdating thay đổi
    final isUpdating = context.select<ProfileController, bool>(
          (c) => c.isUpdating,
    );
    final userData = context.select<ProfileController, Map<String, dynamic>?>(
          (c) => c.userData,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: kPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child:
            isUpdating
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kPrimaryColor,
                ),
              ),
            )
                : TextButton(
              onPressed: _save,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AVATAR ────────────────────────────────────────────────────
              Center(child: _buildAvatarPicker(userData?['ImgURL'])),
              const SizedBox(height: 32),

              // ── HỌ VÀ TÊN ─────────────────────────────────────────────────
              _buildLabel('Họ và tên'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _fullNameCtrl,
                hint: 'Nhập họ và tên',
                icon: LucideIcons.user,
                validator:
                    (v) =>
                v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── TUỔI ──────────────────────────────────────────────────────
              _buildLabel('Tuổi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ageCtrl,
                hint: 'Nhập tuổi',
                icon: LucideIcons.calendarDays,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập tuổi';
                  }
                  final age = int.tryParse(v);
                  if (age == null || age < 1 || age > 120) {
                    return 'Tuổi không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── GIỚI TÍNH ─────────────────────────────────────────────────
              _buildLabel('Giới tính'),
              const SizedBox(height: 8),
              _buildGenderSelector(),
              const SizedBox(height: 20),

              // ── ĐỊA CHỈ ───────────────────────────────────────────────────
              _buildLabel('Địa chỉ'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressCtrl,
                hint: 'Nhập địa chỉ',
                icon: LucideIcons.mapPin,
                maxLines: 2,
              ),
              const SizedBox(height: 40),

              // ── NÚT LƯU ──────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isUpdating ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child:
                  isUpdating
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Lưu thay đổi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AVATAR PICKER ───────────────────────────────────────────────────────────
  Widget _buildAvatarPicker(String? imgUrl) {
    final String displayUrl = ImageUrlHelper.build(imgUrl);
    const String defaultAvatarUrl =
        'https://i.pinimg.com/736x/bc/43/98/bc439871417621836a0eeea768d60944.jpg';
    final String finalUrl =
    displayUrl.isNotEmpty ? displayUrl : defaultAvatarUrl;

    return GestureDetector(
      onTap: _pickAvatar,
      child: SizedBox(
        height: 115,
        width: 115,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 57.5,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child:
                _pickedAvatar != null
                    ? Image.file(
                  _pickedAvatar!,
                  fit: BoxFit.cover,
                  width: 115,
                  height: 115,
                )
                    : CachedNetworkImage(
                  imageUrl: finalUrl,
                  fit: BoxFit.cover,
                  width: 115,
                  height: 115,
                  placeholder:
                      (context, url) => Container(
                    color: Colors.grey[300],
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget:
                      (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            if (_pickedAvatar != null)
              Positioned.fill(
                child: ClipOval(
                  child: Container(color: Colors.black.withOpacity(0.15)),
                ),
              ),
            Positioned(
              right: -16,
              bottom: 0,
              child: SizedBox(
                height: 46,
                width: 46,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFF5F6F9),
                  ),
                  onPressed: _pickAvatar,
                  child: const Icon(
                    LucideIcons.camera,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LABEL ───────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.3,
      ),
    );
  }

  // ─── TEXT FIELD ──────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: kPrimaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFFF5F6F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ─── GENDER SELECTOR ─────────────────────────────────────────────────────────
  Widget _buildGenderSelector() {
    return Row(
      children:
      _genderOptions.map((option) {
        final isSelected = _selectedGender == option['value'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap:
                  () => setState(
                    () => _selectedGender = option['value']!,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                  isSelected
                      ? kPrimaryColor
                      : const Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                    isSelected ? kPrimaryColor : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    option['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight:
                      isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}