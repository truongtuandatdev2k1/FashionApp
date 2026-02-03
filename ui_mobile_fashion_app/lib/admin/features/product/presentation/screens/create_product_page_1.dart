// lib/admin/features/product/presentation/screens/create_product_page_1.dart

import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// Import các controller
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/category_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/style_controller.dart';
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/create_basic_product_controller.dart';

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

  // [THAY ĐỔI 1] Đổi từ String? sang List<String> để lưu nhiều ID
  List<String> _selectedStyleIds = [];

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

  // Helper để hiển thị tên các style đã chọn ra màn hình
  String _getSelectedStyleNames() {
    if (_selectedStyleIds.isEmpty) return '';

    // Lọc ra các object Style có id nằm trong danh sách đã chọn
    final selectedStyles = _styleController.styles
        .where((element) => _selectedStyleIds.contains(element.id.toString()))
        .map((e) => e.displayName)
        .toList();

    return selectedStyles.join(', '); // Nối lại thành chuỗi: "Hàn Quốc, Vintage"
  }

  // [THAY ĐỔI 2] Hàm hiển thị Dialog chọn nhiều phong cách
  void _showMultiSelectStyleDialog() {
    // Tạo bản sao tạm thời để user thao tác, chỉ khi bấm OK mới lưu vào state chính
    List<String> tempSelectedIds = List.from(_selectedStyleIds);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Cần StatefulBuilder để cập nhật UI bên trong Dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chọn phong cách'),
              content: SizedBox(
                width: double.maxFinite,
                child: _styleController.styles.isEmpty
                    ? const Center(child: Text("Đang tải hoặc không có dữ liệu..."))
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _styleController.styles.length,
                  itemBuilder: (context, index) {
                    final style = _styleController.styles[index];
                    final styleIdStr = style.id.toString();
                    final isSelected = tempSelectedIds.contains(styleIdStr);

                    return CheckboxListTile(
                      title: Text(style.displayName),
                      value: isSelected,
                      activeColor: Colors.black,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedIds.add(styleIdStr);
                          } else {
                            tempSelectedIds.remove(styleIdStr);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Lưu thay đổi vào State chính của màn hình
                    setState(() {
                      _selectedStyleIds = tempSelectedIds;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ảnh đại diện')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }
    // [THAY ĐỔI 3] Kiểm tra list rỗng thay vì null
    if (_selectedStyleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất 1 phong cách')));
      return;
    }

    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final discount = int.tryParse(_discountController.text.trim()) ?? 0;

    // [THAY ĐỔI 4] Chuyển List<String> thành List<int>
    final styleIdsInt = _selectedStyleIds.map((e) => int.parse(e)).toList();

    await _createController.createBasicProduct(
      name: _nameController.text.trim(),
      price: price,
      discountPct: discount,
      brandId: widget.brandId,
      categoryId: int.parse(_selectedCategoryId!),
      styleIds: styleIdsInt, // Truyền list int vào đây
      isHotTrend: _isHotTrend,
      ageRange: _ageRangeController.text.trim(),
      description: _descriptionController.text.trim(),
      imageBytes: _imageBytes!,
      imageFileName: _imageFileName!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                        top: 8, right: 8,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DANH MỤC (Dropdown đơn - Giữ nguyên)
              Expanded(
                child: AnimatedBuilder(
                  animation: _categoryController,
                  builder: (context, _) {
                    if (_categoryController.isLoading) return const Center(child: CircularProgressIndicator());
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

              // PHONG CÁCH (Multi-select - Đã thay đổi)
              Expanded(
                child: AnimatedBuilder(
                  animation: _styleController,
                  builder: (context, _) {
                    if (_styleController.isLoading) return const Center(child: CircularProgressIndicator());

                    // Widget giả lập Dropdown bằng InputDecorator + InkWell
                    return InkWell(
                      onTap: _showMultiSelectStyleDialog, // Bấm vào để hiện dialog chọn
                      child: InputDecorator(
                        decoration: _inputDecoration('Phong cách', suffix: null),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedStyleIds.isEmpty
                                    ? 'Chọn phong cách'
                                    : _getSelectedStyleNames(), // Hiển thị tên các style đã chọn
                                style: TextStyle(
                                  color: _selectedStyleIds.isEmpty ? Colors.grey.shade600 : Colors.black,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
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