// lib/customer/views/product/widgets/product_detail/body/image_section.dart
import 'package:flutter/material.dart';

class ProductImageSection extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageSection({super.key, required this.imageUrls});

  @override
  State<ProductImageSection> createState() => _ProductImageSectionState();
}

class _ProductImageSectionState extends State<ProductImageSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageSize = screenHeight * 0.6; // TĂNG LÊN ĐỂ TRÀN DƯỚI HEADER

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: imageSize,
          width: double.infinity,
          color: const Color(0xFFF7F7F7),
          child: PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return Center(
                child: ClipRect(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    width: imageSize,
                    height: imageSize,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
        // PAGE INDICATOR
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: Text(
              '${_currentIndex + 1}/${widget.imageUrls.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}