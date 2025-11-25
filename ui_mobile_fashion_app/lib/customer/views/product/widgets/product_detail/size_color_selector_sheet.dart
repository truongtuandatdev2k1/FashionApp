// lib/customer/views/product/widgets/product_detail/size_color_selector_sheet.dart
import 'package:flutter/material.dart';

class SizeColorSelectorSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  final bool isBuyNow; // true = Buy Now, false = Add to Cart

  const SizeColorSelectorSheet({
    super.key,
    required this.onConfirm,
    this.isBuyNow = false,
  });

  // Hàm tiện ích để hiển thị sheet
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    required bool isBuyNow,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizeColorSelectorSheet(
        onConfirm: onConfirm,
        isBuyNow: isBuyNow,
      ),
    );
  }

  @override
  State<SizeColorSelectorSheet> createState() => _SizeColorSelectorSheetState();
}

class _SizeColorSelectorSheetState extends State<SizeColorSelectorSheet> {
  String? selectedSize;
  String? selectedColor;

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<Map<String, dynamic>> colors = [
    {'name': 'Đen', 'color': Colors.black},
    {'name': 'Trắng', 'color': Colors.white},
    {'name': 'Xanh Navy', 'color': const Color(0xFF1A2A44)},
    {'name': 'Đỏ', 'color': Colors.red},
    {'name': 'Xám', 'color': Colors.grey},
  ];

  String get _confirmButtonText {
    return widget.isBuyNow ? 'Mua ngay' : 'Thêm vào giỏ hàng';
  }

  String get _titleText {
    return widget.isBuyNow ? 'Xác nhận mua ngay' : 'Chọn kích thước & màu sắc';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final modalHeight = height * 0.72;

    return Container(
      height: modalHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Thanh kéo + nút đóng
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 28),
                      splashRadius: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tiêu đề động
          Text(
            _titleText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn Size
                  const Text('Kích thước', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: sizes.map((size) {
                      final isSelected = selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade400,
                              width: isSelected ? 2 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Chọn Màu
                  const Text('Màu sắc', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: colors.map((item) {
                      final color = item['color'] as Color;
                      final name = item['name'] as String;
                      final isSelected = selectedColor == name;

                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = name),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.transparent,
                                  width: isSelected ? 3 : 0,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 32)
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(name, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // Nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (selectedSize != null && selectedColor != null)
                          ? () {
                              widget.onConfirm();
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0079C2),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _confirmButtonText,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}