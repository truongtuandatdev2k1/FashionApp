// lib/admin/features/product/presentation/screens/create_product_page_1.dart

import 'dart:io'; // Cần import để xử lý File ảnh trên mobile
import 'package:flutter/foundation.dart' show kIsWeb; // Import để check platform

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Import thư viện chọn ảnh

class CreateProductPage1 extends StatefulWidget {
  final int brandId;
  final String brandName;

  const CreateProductPage1({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<CreateProductPage1> createState() => _CreateProductPage1State();
}

class _CreateProductPage1State extends State<CreateProductPage1> {
  // Thay đổi từ bool sang XFile để lưu ảnh thật
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  String? _selectedStyle;
  bool _isHotTrend = false;

  final List<String> _categories = ['Áo', 'Quần', 'Bộ', 'Váy', 'Phụ kiện'];
  final List<String> _styles = [
    'Hàn Quốc',
    'Đơn giản',
    'Đường phố',
    'Thể thao',
    'Cổ điển',
    'Công sở'
  ];

  // Hàm xử lý chọn ảnh từ thư viện máy
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  // Input Decoration thống nhất (Flat style)
  InputDecoration _inputDecoration(String label, {IconData? icon, String? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey.shade500) : null,
      // Border khi chưa focus
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300), // Viền xám nhẹ
      ),
      // Border khi đang focus
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5), // Viền đen khi nhập
      ),
      // Border khi có lỗi (mặc định)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.white, // Nền trắng phẳng
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey.shade600),
      floatingLabelStyle: const TextStyle(color: Colors.black),
    );
  }

  void _simulateSubmit() {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh đại diện')),
      );
      return;
    }
    // Demo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bước 1 hoàn tất → Chuyển sang bước 2'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push(
      '/brands/products/create/step2?brandId=${widget.brandId}&brandName=${Uri.encodeComponent(widget.brandName)}&productId=10',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền xám rất nhạt, phẳng
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0, // Bỏ đổ bóng AppBar
        shadowColor: Colors.transparent,
        // border: Border(bottom: BorderSide(color: Colors.grey.shade200)), // Thêm viền mỏng thay cho bóng
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm Sản Phẩm Mới',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Bước 1/3: Thông tin cơ bản - ${widget.brandName}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined, color: Colors.grey, size: 20),
              label: const Text('Lưu nháp', style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: isWideScreen
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLeftColumn()),
                const SizedBox(width: 24),
                Expanded(flex: 7, child: _buildRightColumn()),
              ],
            )
                : Column(
              children: [
                _buildLeftColumn(),
                const SizedBox(height: 24),
                _buildRightColumn(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          // Bỏ boxShadow, thay bằng viền trên
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: const Text('Hủy bỏ', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _simulateSubmit,
              icon: const Icon(Icons.arrow_forward, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0, // Nút phẳng
              ),
              label: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildLeftColumn() {
    return Column(
      children: [
        // Card Ảnh - Đã tích hợp sự kiện chọn ảnh
        _buildCardContainer(
          title: 'Hình ảnh đại diện',
          child: GestureDetector(
            onTap: _pickedImage == null ? _pickImage : null, // Chỉ cho nhấn khi chưa có ảnh
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  // Viền nét đứt nếu chưa có ảnh, viền trơn nếu đã có
                  border: Border.all(
                      color: _pickedImage == null ? Colors.grey.shade400 : Colors.transparent,
                      style: _pickedImage == null ? BorderStyle.solid : BorderStyle.none,
                      width: 1.5
                  ),
                ),
                child: _pickedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hiển thị ảnh - Tương thích với cả Web và Mobile
                      _buildImageWidget(),
                      // Nút xóa ảnh ở góc trên
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _pickedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      // Nút "Đổi ảnh khác" ở dưới cùng
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.swap_horiz, size: 18),
                            label: const Text('Đổi ảnh khác'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                // Placeholder khi chưa chọn ảnh
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Nhấn để tải ảnh lên', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Card Trạng thái
        _buildCardContainer(
          title: 'Hiển thị',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sản phẩm Hot Trend', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Sản phẩm sẽ có nhãn "Hot" khi hiển thị', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                value: _isHotTrend,
                onChanged: (val) => setState(() => _isHotTrend = val),
                activeColor: Colors.black,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget hiển thị ảnh tương thích với cả Web và Mobile
  Widget _buildImageWidget() {
    if (_pickedImage == null) {
      return const SizedBox();
    }

    if (kIsWeb) {
      // Trên Web: sử dụng Image.network với URL blob
      return Image.network(
        _pickedImage!.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text('Lỗi hiển thị ảnh', style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        },
      );
    } else {
      // Trên Mobile/Desktop: sử dụng Image.file
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text('Lỗi hiển thị ảnh', style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        // Card Thông tin chung
        _buildCardContainer(
          title: 'Thông tin chung',
          child: Column(
            children: [
              TextFormField(
                decoration: _inputDecoration('Tên sản phẩm'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 5,
                decoration: _inputDecoration('Mô tả sản phẩm').copyWith(alignLabelWithHint: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Card Phân loại
        _buildCardContainer(
          title: 'Phân loại & Phong cách',
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration('Danh mục'),
                  hint: const Text('Chọn danh mục'),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStyle,
                  decoration: _inputDecoration('Phong cách'),
                  hint: const Text('Chọn phong cách'),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  items: _styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _selectedStyle = v),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Card Giá bán
        _buildCardContainer(
          title: 'Giá bán',
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Giá gốc', suffix: 'VND'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Giảm giá', suffix: '%'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Wrapper Widget cho các khối Card - PHIÊN BẢN FLAT (KHÔNG BÓNG)
  Widget _buildCardContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Thay vì boxShadow, ta dùng border mỏng
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}