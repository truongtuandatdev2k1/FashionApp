// lib/customer/views/product/widgets/product_detail/size_color_selector_sheet.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/cart/add_to_cart_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/product_detail_model.dart';

class SizeColorSelectorSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  final bool isBuyNow;
  final ProductDetailModel product;

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
  String? selectedColorHex;
  int _quantity = 1;
  bool _isAdding = false;

  late List<String> availableSizes;
  late List<ColorInfo> availableColors;
  late Map<String, List<Variant>> variantsByColorHex;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    variantsByColorHex = {};
    for (var v in widget.product.variants) {
      final hex = v.colorHex.trim();
      variantsByColorHex.putIfAbsent(hex, () => []);
      variantsByColorHex[hex]!.add(v);
    }

    availableColors = widget.product.colors;

    if (availableColors.isNotEmpty) {
      selectedColorHex = availableColors.first.hex.trim();
      _updateSizesForSelectedColor();
    }
  }

  void _updateSizesForSelectedColor() {
    if (selectedColorHex == null) return;

    final sizes =
        variantsByColorHex[selectedColorHex]!
            .map((v) => v.sizeCode)
            .toSet()
            .toList()
          ..sort();

    availableSizes = sizes;

    if (availableSizes.isNotEmpty &&
        (selectedSize == null || !availableSizes.contains(selectedSize))) {
      selectedSize = availableSizes.first;
    }

    // Reset số lượng khi đổi màu/size
    setState(() => _quantity = 1);
  }

  String get _selectedImageUrl {
    if (selectedColorHex == null || selectedSize == null)
      return widget.product.imageUrl;

    final variant = variantsByColorHex[selectedColorHex]!.firstWhere(
      (v) => v.sizeCode == selectedSize,
      orElse: () => variantsByColorHex[selectedColorHex]!.first,
    );

    return variant.images.isNotEmpty
        ? variant.images.first
        : widget.product.imageUrl;
  }

  int get _currentStock {
    if (selectedColorHex == null || selectedSize == null) return 0;

    try {
      return variantsByColorHex[selectedColorHex]!
          .firstWhere((v) => v.sizeCode == selectedSize)
          .stock;
    } catch (_) {
      return 0;
    }
  }

  int? get _selectedVariantId {
    if (selectedColorHex == null || selectedSize == null) return null;

    try {
      return variantsByColorHex[selectedColorHex]!
          .firstWhere((v) => v.sizeCode == selectedSize)
          .id;
    } catch (_) {
      return null;
    }
  }

  Future<void> _addToCart() async {
    final variantId = _selectedVariantId;
    if (variantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ màu sắc và kích thước'),
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      await AddToCartApi.addToCart(variantId, _quantity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm vào giỏ hàng thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onConfirm();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
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

          // Ảnh + giá
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            '${(widget.product.priceAfter / 1000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(widget.product.price / 1000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                  // Kích thước
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
                          final isOutOfStock = _currentStock == 0;
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

                  // Màu sắc
                  const Text(
                    'Màu sắc',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        availableColors
                            .where(
                              (c) =>
                                  c.hex.trim().isNotEmpty &&
                                  RegExp(r'^#?[0-9A-Fa-f]{6}$').hasMatch(
                                    c.hex.trim().replaceFirst('#', ''),
                                  ),
                            )
                            .map((colorInfo) {
                              final hex = colorInfo.hex.trim();
                              final cleanHex =
                                  hex.startsWith('#') ? hex : '#$hex';
                              final isSelected =
                                  selectedColorHex?.trim() == cleanHex;
                              final color = Color(
                                int.parse(cleanHex.replaceFirst('#', '0xFF')),
                              );
                              final luminance = color.computeLuminance();
                              final isLight = luminance > 0.9;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColorHex = cleanHex;
                                    _updateSizesForSelectedColor();
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.black
                                                  : (isLight
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade300),
                                          width:
                                              isSelected
                                                  ? 3.8
                                                  : (isLight ? 2.2 : 1.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              isSelected ? 0.4 : 0.2,
                                            ),
                                            blurRadius: isSelected ? 16 : 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 36,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      colorInfo.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                  ),
                  const SizedBox(height: 32),

                  // === SỐ LƯỢNG - CÙNG MỘT HÀNG ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cột trái: Text "Số lượng"
                      const Text(
                        'Số lượng',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Cột phải: Phần chọn số lượng
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 32,
                            ),
                            color: _quantity > 1 ? Colors.black : Colors.grey,
                            onPressed:
                                _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                          ),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 32,
                            ),
                            color:
                                _quantity < _currentStock
                                    ? Colors.black
                                    : Colors.grey,
                            onPressed:
                                _quantity < _currentStock
                                    ? () => setState(() => _quantity++)
                                    : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ), // Khoảng cách xuống nút "Thêm vào giỏ hàng"
                  const Spacer(),

                  // Nút thêm vào giỏ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isAdding ||
                                  selectedSize == null ||
                                  selectedColorHex == null ||
                                  _currentStock == 0 ||
                                  _quantity == 0
                              ? null
                              : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0079C2),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isAdding
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
                                widget.isBuyNow
                                    ? 'Mua ngay'
                                    : 'Thêm vào giỏ hàng',
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
