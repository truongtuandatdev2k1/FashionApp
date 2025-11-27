// lib/customer/views/product/widgets/product_detail/size_color_selector_sheet.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_detail_model.dart';

class SizeColorSelectorSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  final bool isBuyNow;
  final ProductDetailModel product; // THÊM PRODUCT ĐỂ LẤY DATA

  const SizeColorSelectorSheet({
    super.key,
    required this.onConfirm,
    required this.product,
    this.isBuyNow = false,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductDetailModel product,
    required VoidCallback onConfirm,
    required bool isBuyNow,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => SizeColorSelectorSheet(
            product: product,
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

  late List<String> availableSizes;
  late List<Map<String, dynamic>> availableColors;
  late Map<String, List<Variant>> variantsByColor;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    variantsByColor = {};
    for (var v in widget.product.variants) {
      variantsByColor.putIfAbsent(v.colorName, () => []);
      variantsByColor[v.colorName]!.add(v);
    }

    availableColors =
        widget.product.colors
            .map((c) => {'name': c.name, 'hex': c.hex})
            .toList();

    if (availableColors.isNotEmpty) {
      selectedColor = availableColors.first['name'] as String;
      _updateSizesForSelectedColor();
    }
  }

  void _updateSizesForSelectedColor() {
    if (selectedColor == null) return;
    final sizes =
        variantsByColor[selectedColor]!.map((v) => v.sizeCode).toSet().toList()
          ..sort();
    availableSizes = sizes;

    if (availableSizes.isNotEmpty &&
        (selectedSize == null || !availableSizes.contains(selectedSize))) {
      selectedSize = availableSizes.first;
    }
  }

  String get _selectedImageUrl {
    if (selectedColor == null) return widget.product.imageUrl;
    final variant = variantsByColor[selectedColor]!.firstWhere(
      (v) => v.sizeCode == selectedSize,
      orElse: () => variantsByColor[selectedColor]!.first,
    );
    return variant.images.isNotEmpty
        ? variant.images.first
        : widget.product.imageUrl;
  }

  int get _currentStock {
    if (selectedColor == null || selectedSize == null) return 0;
    try {
      return variantsByColor[selectedColor]!
          .firstWhere((v) => v.sizeCode == selectedSize)
          .stock;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Thanh kéo + đóng
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
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // PHẦN MỚI: THÔNG TIN SẢN PHẨM + ẢNH NHỎ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột trái: Ảnh nhỏ
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // ignore: sized_box_for_whitespace
                  child: Container(
                    width: 90,
                    height: 90,
                    child: CachedNetworkImage(
                      imageUrl: _selectedImageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            color: Colors.grey[200],
                            child: const CircularProgressIndicator(),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Cột phải: Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Giảm giá + giá mới
                      Row(
                        children: [
                          if (widget.product.discountPct > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${widget.product.discountPct}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '${(widget.product.priceAfter / 1000).toStringAsFixed(3).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Giá cũ
                      Text(
                        '${(widget.product.price / 1000).toStringAsFixed(3).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tồn kho
                      Text(
                        'Kho: $_currentStock',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn Size
                  const Text(
                    'Kích thước',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        availableSizes.map((size) {
                          final isSelected = selectedSize == size;
                          final stock =
                              variantsByColor[selectedColor]!
                                  .firstWhere((v) => v.sizeCode == size)
                                  .stock;
                          final isOutOfStock = stock == 0;

                          return GestureDetector(
                            onTap:
                                isOutOfStock
                                    ? null
                                    : () => setState(() => selectedSize = size),
                            child: Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.black
                                        : (isOutOfStock
                                            ? Colors.grey[200]
                                            : Colors.transparent),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : (isOutOfStock
                                              ? Colors.grey
                                              : Colors.black),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Chọn Màu
                  const Text(
                    'Màu sắc',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        availableColors.map((item) {
                          final name = item['name'] as String;
                          final hex = item['hex'] as String;
                          final color =
                              hex == '#FFFFFF'
                                  ? Colors.white
                                  : Color(
                                    int.parse(hex.replaceFirst('#', '0xFF')),
                                  );
                          final isSelected = selectedColor == name;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = name;
                                _updateSizesForSelectedColor();
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.black
                                              : Colors.transparent,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 32,
                                          )
                                          : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 13),
                                ),
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
                      onPressed:
                          (selectedSize != null &&
                                  selectedColor != null &&
                                  _currentStock > 0)
                              ? () {
                                widget.onConfirm();
                                Navigator.of(context).pop();
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0079C2),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.isBuyNow ? 'Mua ngay' : 'Thêm vào giỏ hàng',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
