// lib/admin/features/product/presentation/screens/create_product_page_2.dart

import 'dart:io'; // Để dùng File (Mobile)
import 'package:flutter/foundation.dart' show kIsWeb; // Để check Web
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart'; // Thư viện chọn ảnh

// Import Controller
import 'package:ui_mobile_fashion_app/admin/features/product/presentation/logic/create_product_variants_controller.dart';

class CreateProductPage2 extends StatefulWidget {
  final int brandId;
  final String brandName;
  final int productId;

  const CreateProductPage2({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.productId,
  });

  @override
  State<CreateProductPage2> createState() => _CreateProductPage2State();
}

class _CreateProductPage2State extends State<CreateProductPage2> {
  // [LOGIC MỚI] Controller & Picker
  final CreateProductVariantsController _controller = CreateProductVariantsController();
  final ImagePicker _picker = ImagePicker();

  final List<String> _availableSizes = ['S', 'M', 'L', 'XL', '2XL'];

  // [LOGIC MỚI] Sửa String -> XFile để chứa ảnh thật
  final List<Map<String, dynamic>> _colors = [];

  int? _selectedColorIndex;
  Color _tempColor = Colors.black;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- LOGIC GỌI API (THAY CHO _simulateComplete) ---
  Future<void> _handleSubmit() async {
    if (_colors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm màu sắc')));
      return;
    }

    final success = await _controller.createProductVariants(
      productId: widget.productId,
      uiColors: _colors,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sản phẩm đã được tạo thành công!'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Back 2 lần
        context.pop();
        context.pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.errorMessage ?? 'Lỗi'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LOGIC CHỌN ẢNH THẬT (THAY CHO _addDemoImage) ---
  Future<void> _pickImages() async {
    if (_selectedColorIndex == null) return;
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          (_colors[_selectedColorIndex!]['images'] as List<XFile>).addAll(pickedFiles);
        });
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  void _showColorPickerDialog() {
    Color pickerColor = _tempColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Chọn màu sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              colorPickerWidth: 280.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
              pickerAreaBorderRadius: BorderRadius.circular(8),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  final hex = '#${pickerColor.value.toRadixString(16).substring(2).toUpperCase()}';
                  _colors.add({
                    'hex': hex,
                    'images': <XFile>[], // [SỬA] List rỗng kiểu XFile
                    'selectedSizes': <String>{},
                    'stocks': <String, int>{},
                  });
                  _selectedColorIndex = _colors.length - 1;
                });
                Navigator.pop(context);
              },
              child: const Text('Thêm màu'),
            ),
          ],
        );
      },
    );
  }

  void _removeColor(int index) {
    setState(() {
      if (_selectedColorIndex == index) _selectedColorIndex = null;
      _colors.removeAt(index);
      if (_colors.isNotEmpty && _selectedColorIndex == null) {
        _selectedColorIndex = 0;
      } else if (_colors.isEmpty) {
        _selectedColorIndex = null;
      }
    });
  }

  void _removeImage(int colorIndex, int imgIndex) {
    setState(() {
      (_colors[colorIndex]['images'] as List<XFile>).removeAt(imgIndex);
    });
  }

  void _toggleSizeForCurrentColor(String size, bool selected) {
    if (_selectedColorIndex == null) return;
    final colorData = _colors[_selectedColorIndex!];
    final selectedSizes = colorData['selectedSizes'] as Set<String>;
    final stocks = colorData['stocks'] as Map<String, int>;

    setState(() {
      if (selected) {
        selectedSizes.add(size);
        stocks[size] = 0;
      } else {
        selectedSizes.remove(size);
        stocks.remove(size);
      }
    });
  }

  // --- UI COMPONENTS ---

  InputDecoration _inputDecoration(String label, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [LOGIC MỚI] Wrap ListenableBuilder để rebuild khi loading
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final currentColor = _selectedColorIndex != null ? _colors[_selectedColorIndex!] : null;

        return Stack(
          children: [
            Scaffold(
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
                    const Text(
                      'Biến thể sản phẩm',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Bước 2/3: Màu sắc & Kích cỡ',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                          child: Text('ID: ${widget.productId}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.brandName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // PHẦN 1: QUẢN LÝ MÀU SẮC
                    _buildCardContainer(
                      title: 'Danh sách màu sắc',
                      action: TextButton.icon(
                        onPressed: _showColorPickerDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm màu'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
                      ),
                      child: _colors.isEmpty
                          ? _buildEmptyColorState()
                          : SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _colors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) => _buildColorItem(index),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PHẦN 2: CHI TIẾT
                    if (currentColor != null)
                      _buildDetailSection(currentColor)
                    else if (_colors.isNotEmpty)
                      Center(
                        child: Text('Chọn một màu phía trên để cấu hình chi tiết',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
              bottomNavigationBar: _buildBottomBar(),
            ),

            // [LOGIC MỚI] Loading Overlay
            if (_controller.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  // --- WIDGET LOGIC ---

  Widget _buildDetailSection(Map<String, dynamic> currentColorData) {
    return Column(
      children: [
        // 2.1: Ảnh của màu
        _buildCardContainer(
          title: 'Hình ảnh (Màu ${_selectedColorIndex != null ? _colors[_selectedColorIndex!]['hex'] : ''})',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tải lên hình ảnh thực tế cho phiên bản màu này.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Nút thêm ảnh (GỌI HÀM PICKER)
                    InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Thêm', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // List ảnh
                    ...((currentColorData['images'] as List<XFile>).asMap().entries.map((entry) {
                      return _buildImageItem(entry.key, entry.value);
                    })),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2.2: Size & Stock
        _buildCardContainer(
          title: 'Kích cỡ & Tồn kho',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn các size có sẵn cho màu này:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSizes.map((size) {
                  final selectedSizes = currentColorData['selectedSizes'] as Set<String>;
                  final isSelected = selectedSizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (val) => _toggleSizeForCurrentColor(size, val),
                    showCheckmark: false,
                    selectedColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const Divider(height: 32),

              // List Stock Input
              if ((currentColorData['selectedSizes'] as Set).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nhập số lượng tồn kho:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 16),
                    // Grid input
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: (currentColorData['selectedSizes'] as Set<String>).map((size) {
                        final stocks = currentColorData['stocks'] as Map<String, int>;
                        return SizedBox(
                          width: 140,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Size $size', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextFormField(
                                initialValue: stocks[size]?.toString() ?? '0',
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('', suffix: 'cái'),
                                onChanged: (val) => stocks[size] = int.tryParse(val) ?? 0,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Vui lòng chọn ít nhất 1 size ở trên', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required String title, required Widget child, Widget? action}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyColorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.palette_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('Chưa có màu nào được tạo', style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            const Text('Nhấn "Thêm màu" để bắt đầu', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(int index) {
    final hex = _colors[index]['hex'] as String;
    final colorVal = int.parse(hex.replaceFirst('#', '0xFF'));
    final isSelected = index == _selectedColorIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(colorVal),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(color: Color(colorVal).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                  ]
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => _removeColor(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.shade100),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // [LOGIC MỚI] Sửa String -> XFile và check kIsWeb để hiển thị ảnh
  Widget _buildImageItem(int imgIndex, XFile file) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              // [QUAN TRỌNG] Hiển thị ảnh khác nhau giữa Web và Mobile
              child: kIsWeb
                  ? Image.network(file.path, fit: BoxFit.cover)
                  : Image.file(File(file.path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _removeImage(_selectedColorIndex!, imgIndex),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('Quay lại', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton.icon(
            onPressed: _handleSubmit, // [GỌI HÀM SUBMIT MỚI]
            icon: const Icon(Icons.check, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            label: const Text('Hoàn thành', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}