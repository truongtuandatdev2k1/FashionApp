// lib/admin/features/product/presentation/screens/create_product_page_1.dart

import 'dart:typed_data';
import 'package:dio/dio.dart' as dio; // Dùng Dio cho multipart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// Import các controller
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/category_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/style_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/create_basic_product_controller.dart';
import 'package:ui_mobile_fashion_app/core/network/api_client.dart'; // ← ApiClient dùng Dio

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
  String? _imageFileName;
  final ImagePicker _picker = ImagePicker();

  // Controllers logic
  late final CategoryController _categoryController;
  late final StyleController _styleController;
  late final CreateBasicProductController _createController;

  // Input controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ageRangeController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedStyleId; // Chỉ chọn 1 phong cách (nếu muốn multi → đổi thành List<String>)
  bool _isHotTrend = false;

  @override
  void initState() {
    super.initState();
    _categoryController = CategoryController();
    _styleController = StyleController();
    _createController = CreateBasicProductController();

    _categoryController.addListener(_onDataChanged);
    _styleController.addListener(_onDataChanged);
    _createController.addListener(_onCreateChanged);

    _categoryController.fetchCategories();
    _styleController.fetchStyles();
  }

  @override
  void dispose() {
    _categoryController.removeListener(_onDataChanged);
    _styleController.removeListener(_onDataChanged);
    _createController.removeListener(_onCreateChanged);

    _categoryController.dispose();
    _styleController.dispose();
    _createController.dispose();

    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _ageRangeController.dispose();

    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _onCreateChanged() {
    if (mounted) {
      setState(() {});
      if (_createController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_createController.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (_createController.createdProductId != null) {
        context.push(
          '/brands/products/create/step2?'
              'brandId=${widget.brandId}&'
              'brandName=${Uri.encodeComponent(widget.brandName)}&'
              'productId=${_createController.createdProductId}',
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFileName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e'), backgroundColor: Colors.red),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey.shade600),
      floatingLabelStyle: const TextStyle(color: Colors.black),
    );
  }

  Future<void> _submit() async {
    if (_imageBytes == null || _imageFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh đại diện'), backgroundColor: Colors.red, duration: Duration(seconds: 3)),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục'), backgroundColor: Colors.red, duration: Duration(seconds: 3)),
      );
      return;
    }
    if (_selectedStyleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phong cách'), backgroundColor: Colors.red, duration: Duration(seconds: 3)),
      );
      return;
    }

    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final discount = int.tryParse(_discountController.text.trim()) ?? 0;

    final success = await _createController.createBasicProduct(
      name: _nameController.text.trim(),
      price: price,
      discountPct: discount,
      brandId: widget.brandId,
      categoryId: int.parse(_selectedCategoryId!),
      styleIds: _selectedStyleId != null ? [int.parse(_selectedStyleId!)] : [],
      isHotTrend: _isHotTrend,
      ageRange: _ageRangeController.text.trim(),
      description: _descriptionController.text.trim(),
      imageBytes: _imageBytes!,
      imageFileName: _imageFileName!,
    );

    // Không cần push ở đây nữa, controller sẽ xử lý
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
              onPressed: _createController.isLoading ? null : _submit,
              icon: _createController.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.arrow_forward, size: 18),
              label: Text(_createController.isLoading ? 'Đang tạo...' : 'Tiếp tục'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
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
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Tên sản phẩm'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _inputDecoration('Mô tả sản phẩm').copyWith(alignLabelWithHint: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildCardContainer(
          title: 'Phân loại & Phong cách',
          child: Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _categoryController,
                  builder: (context, _) {
                    if (_categoryController.isLoading) return const Center(child: CircularProgressIndicator());
                    if (_categoryController.error != null) return Text(_categoryController.error!, style: const TextStyle(color: Colors.red));
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: _inputDecoration('Danh mục'),
                      hint: const Text('Chọn danh mục'),
                      items: _categoryController.categories.map((cat) => DropdownMenuItem(value: cat.id.toString(), child: Text(cat.displayName))).toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: _styleController,
                  builder: (context, _) {
                    if (_styleController.isLoading) return const Center(child: CircularProgressIndicator());
                    if (_styleController.error != null) return Text(_styleController.error!, style: const TextStyle(color: Colors.red));
                    return DropdownButtonFormField<String>(
                      value: _selectedStyleId,
                      decoration: _inputDecoration('Phong cách'),
                      hint: const Text('Chọn phong cách'),
                      items: _styleController.styles.map((s) => DropdownMenuItem(value: s.id.toString(), child: Text(s.displayName))).toList(),
                      onChanged: (v) => setState(() => _selectedStyleId = v),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildCardContainer(
          title: 'Giá bán & Khác',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Giá gốc', suffix: 'VND'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Giảm giá', suffix: '%'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageRangeController,
                decoration: _inputDecoration('Độ tuổi phù hợp (ví dụ: 16-30)'),
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