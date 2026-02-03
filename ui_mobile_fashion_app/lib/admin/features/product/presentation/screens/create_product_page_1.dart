// lib/admin/features/product/presentation/screens/create_product_page_1.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// Import controller mới
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/category_controller.dart';

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
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Controller cho danh mục từ API
  late final CategoryController _categoryController;

  String? _selectedCategoryId; // Lưu ID danh mục được chọn
  String? _selectedStyle;
  bool _isHotTrend = false;

  final List<String> _styles = [
    'Hàn Quốc',
    'Đơn giản',
    'Đường phố',
    'Thể thao',
    'Cổ điển',
    'Công sở'
  ];

  @override
  void initState() {
    super.initState();
    _categoryController = CategoryController();
    // Gọi API ngay khi màn hình load
    _categoryController.addListener(_onCategoryChanged);
    _categoryController.fetchCategories();
  }

  @override
  void dispose() {
    _categoryController.removeListener(_onCategoryChanged);
    _categoryController.dispose();
    super.dispose();
  }

  void _onCategoryChanged() {
    if (mounted) setState(() {}); // Cập nhật UI khi controller thay đổi
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon, String? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey.shade500) : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey.shade600),
      floatingLabelStyle: const TextStyle(color: Colors.black),
    );
  }

  void _simulateSubmit() {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh đại diện'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục'), backgroundColor: Colors.red),
      );
      return;
    }

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thêm Sản Phẩm Mới', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Bước 1/3: Thông tin cơ bản - ${widget.brandName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
                elevation: 0,
              ),
              label: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildCardContainer(
          title: 'Hình ảnh đại diện',
          child: GestureDetector(
            onTap: _pickImage,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _imageBytes == null ? Colors.grey.shade400 : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_imageBytes!, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
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
        if (_imageBytes != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Đổi ảnh khác'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
        const SizedBox(height: 24),
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

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildCardContainer(
          title: 'Thông tin chung',
          child: Column(
            children: [
              TextFormField(decoration: _inputDecoration('Tên sản phẩm')),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 5,
                decoration: _inputDecoration('Mô tả sản phẩm').copyWith(alignLabelWithHint: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Chỉ thay đổi phần Card "Phân loại & Phong cách" trong _buildRightColumn()

        _buildCardContainer(
          title: 'Phân loại & Phong cách',
          child: Row(
            children: [
              // Danh mục từ API (tiếng Việt)
              Expanded(
                child: AnimatedBuilder(
                  animation: _categoryController,
                  builder: (context, child) {
                    if (_categoryController.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.black));
                    }
                    if (_categoryController.error != null) {
                      return Text(
                        _categoryController.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: _inputDecoration('Danh mục'),
                      hint: const Text('Chọn danh mục'),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: _categoryController.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id.toString(),
                          child: Text(cat.displayName), // ← Hiển thị tiếng Việt đẹp
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Phong cách (tiếng Việt, nằm ngang)
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

  Widget _buildCardContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}