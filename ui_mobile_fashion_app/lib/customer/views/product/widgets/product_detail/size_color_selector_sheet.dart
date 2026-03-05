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
      builder: (_) => SizeColorSelectorSheet(
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

    final sizes = variantsByColorHex[selectedColorHex]!
        .map((v) => v.sizeCode)
        .toSet()
        .toList()
      ..sort();

    availableSizes = sizes;

    if (availableSizes.isNotEmpty &&
        (selectedSize == null || !availableSizes.contains(selectedSize))) {
      selectedSize = availableSizes.first;
    }

    setState(() => _quantity = 1);
  }

  String get _selectedImageUrl {
    if (selectedColorHex == null || selectedSize == null) {
      return widget.product.imageUrl;
    }

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

  String _formatCurrency(num price) {
    final raw = price.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return raw.replaceAllMapped(reg, (m) => '${m[1]}.') + ' đ';
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
      height: height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle bar + close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Ảnh + giá
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CachedNetworkImage(
                      imageUrl: _selectedImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Giá + kho
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng 1: Giá sau giảm (màu đen)
                      Text(
                        _formatCurrency(widget.product.priceAfter),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Hàng 2: Giá gốc gạch ngang + % giảm cùng hàng
                      Row(
                        children: [
                          Text(
                            _formatCurrency(widget.product.price),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          if (widget.product.discountPct > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${widget.product.discountPct}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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

          const SizedBox(height: 10),
          const Divider(height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kích thước
                  const Text('Kích thước', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: availableSizes.map((size) {
                      final isSelected = selectedSize == size;
                      final isOutOfStock = _currentStock == 0;
                      return GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () => setState(() => selectedSize = size),
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black
                                : (isOutOfStock
                                ? Colors.grey[200]
                                : Colors.transparent),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade400,
                              width: isSelected ? 2 : 0.5,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isOutOfStock
                                  ? Colors.grey
                                  : Colors.black),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Màu sắc
                  const Text('Màu sắc', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 16,
                    children: availableColors
                        .where((c) =>
                    c.hex.trim().isNotEmpty &&
                        RegExp(r'^#?[0-9A-Fa-f]{6}$').hasMatch(
                          c.hex.trim().replaceFirst('#', ''),
                        ))
                        .map((colorInfo) {
                      final hex = colorInfo.hex.trim();
                      final cleanHex =
                      hex.startsWith('#') ? hex : '#$hex';
                      final isSelected =
                          selectedColorHex?.trim() == cleanHex;
                      final color = Color(
                        int.parse(cleanHex.replaceFirst('#', '0xFF')),
                      );
                      final isLight = color.computeLuminance() > 0.9;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorHex = cleanHex;
                            _updateSizesForSelectedColor();
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : (isLight
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade300),
                              width: isSelected ? 2.0 : 0.0,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                              : null,
                        ),
                      );
                    })
                        .toList(),
                  ),
                  const SizedBox(height: 1),

                  // Số lượng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:',
                          style: TextStyle(fontSize: 14)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                size: 20),
                            color:
                            _quantity > 1 ? Colors.black : Colors.grey,
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          SizedBox(
                            width: 18,
                            child: Center(
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                size: 20),
                            color: _quantity < _currentStock
                                ? Colors.black
                                : Colors.grey,
                            onPressed: _quantity < _currentStock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Nút thêm vào giỏ / mua ngay
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isAdding ||
                          selectedSize == null ||
                          selectedColorHex == null ||
                          _currentStock == 0 ||
                          _quantity == 0
                          ? null
                          : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isAdding
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
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}